#!/usr/bin/env python3
"""
LLM-based validation for ACAI Account Hardening examples.

This script validates that the rendered Terraform output matches
the expected use case described in expected.yaml files.

Supports:
- Azure OpenAI Service
- OpenAI API (direct)
- GitHub Copilot API (via token)

Usage:
    python validate_examples.py [--provider azure|openai|github] [--example account-cluster-1]

Environment Variables Required:
    For Azure OpenAI:
        AZURE_OPENAI_ENDPOINT - Azure OpenAI endpoint URL
        AZURE_OPENAI_API_KEY - Azure OpenAI API key
        AZURE_OPENAI_DEPLOYMENT - Deployment name for GPT-4

    For OpenAI:
        OPENAI_API_KEY - OpenAI API key

    For GitHub Copilot:
        GITHUB_TOKEN - GitHub token with Copilot access
"""

import os
import sys
import json
import argparse
import glob
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional
import yaml

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).parent.resolve()
DEFAULT_MODEL = "gpt-4o"


@dataclass
class ValidationResult:
    """Result of validating a single example."""
    example_name: str
    use_case: str
    passed: bool
    score: float
    findings: list[str] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)
    llm_response: str = ""


# -----------------------------------------------------------------------------
# LLM Providers
# -----------------------------------------------------------------------------
def get_azure_openai_client():
    """Initialize Azure OpenAI client."""
    try:
        from openai import AzureOpenAI
    except ImportError:
        print("ERROR: openai package not installed. Run: pip install openai")
        sys.exit(1)

    endpoint = os.environ.get("AZURE_OPENAI_ENDPOINT")
    api_key = os.environ.get("AZURE_OPENAI_API_KEY")
    deployment = os.environ.get("AZURE_OPENAI_DEPLOYMENT", "gpt-4o")

    if not endpoint or not api_key:
        raise ValueError(
            "Missing Azure OpenAI credentials. Set AZURE_OPENAI_ENDPOINT and AZURE_OPENAI_API_KEY"
        )

    return AzureOpenAI(
        azure_endpoint=endpoint,
        api_key=api_key,
        api_version="2024-02-15-preview"
    ), deployment


def get_openai_client():
    """Initialize OpenAI client."""
    try:
        from openai import OpenAI
    except ImportError:
        print("ERROR: openai package not installed. Run: pip install openai")
        sys.exit(1)

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("Missing OpenAI API key. Set OPENAI_API_KEY")

    return OpenAI(api_key=api_key), DEFAULT_MODEL


def call_llm(provider: str, prompt: str) -> str:
    """Call the LLM with the given prompt."""
    if provider == "azure":
        client, deployment = get_azure_openai_client()
        response = client.chat.completions.create(
            model=deployment,
            messages=[
                {
                    "role": "system",
                    "content": "You are a Terraform code reviewer specializing in AWS security configurations. "
                               "Analyze code against expected requirements and provide structured JSON responses."
                },
                {"role": "user", "content": prompt}
            ],
            temperature=0.1,
            max_tokens=2000
        )
        return response.choices[0].message.content

    elif provider == "openai":
        client, model = get_openai_client()
        response = client.chat.completions.create(
            model=model,
            messages=[
                {
                    "role": "system",
                    "content": "You are a Terraform code reviewer specializing in AWS security configurations. "
                               "Analyze code against expected requirements and provide structured JSON responses."
                },
                {"role": "user", "content": prompt}
            ],
            temperature=0.1,
            max_tokens=2000
        )
        return response.choices[0].message.content

    else:
        raise ValueError(f"Unknown provider: {provider}")


# -----------------------------------------------------------------------------
# Validation Logic
# -----------------------------------------------------------------------------
def load_expected_yaml(example_dir: Path) -> dict:
    """Load expected.yaml from an example directory."""
    yaml_path = example_dir / "expected.yaml"
    if not yaml_path.exists():
        raise FileNotFoundError(f"expected.yaml not found in {example_dir}")

    with open(yaml_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def load_rendered_tf(example_dir: Path) -> dict[str, str]:
    """Load all rendered Terraform files from an example."""
    rendered_dir = example_dir / "rendered-tf"
    if not rendered_dir.exists():
        raise FileNotFoundError(
            f"rendered-tf directory not found in {example_dir}. "
            f"Run 'terraform apply' first."
        )

    files = {}
    for tf_file in rendered_dir.glob("*.tf"):
        with open(tf_file, "r", encoding="utf-8") as f:
            files[tf_file.name] = f.read()

    # Also load .part files (import scripts)
    for part_file in rendered_dir.glob("*.part"):
        with open(part_file, "r", encoding="utf-8") as f:
            files[part_file.name] = f.read()

    return files


def build_validation_prompt(expected: dict, rendered_files: dict[str, str]) -> str:
    """Build the LLM prompt for validation."""
    # Format the expected requirements
    expected_yaml = yaml.dump(expected, default_flow_style=False)

    # Format the rendered files
    files_content = ""
    for filename, content in sorted(rendered_files.items()):
        files_content += f"\n--- {filename} ---\n{content}\n"

    prompt = f"""
Analyze the following Terraform code against the expected requirements.

## Expected Requirements (from expected.yaml):
```yaml
{expected_yaml}
```

## Rendered Terraform Files:
{files_content}

## Task:
1. Check if the rendered files match the expected use case and requirements
2. Verify all expected files are present
3. Check that excluded files are NOT present
4. Validate each feature's expectations against the actual code
5. Check region configuration matches expectations

## Response Format:
Respond with a JSON object in the following format:
```json
{{
    "passed": true|false,
    "score": 0.0-1.0,
    "summary": "Brief summary of validation result",
    "file_checks": {{
        "expected_present": ["list of expected files that ARE present"],
        "expected_missing": ["list of expected files that are MISSING"],
        "unexpected_present": ["list of files that should NOT be present but ARE"]
    }},
    "feature_validations": {{
        "feature_name": {{
            "passed": true|false,
            "findings": ["specific findings for this feature"]
        }}
    }},
    "errors": ["list of critical issues"],
    "warnings": ["list of non-critical issues"]
}}
```

Be strict about:
- File presence/absence matching expected_files and excluded_files
- Region configuration matching expected_regions and excluded_regions
- Feature-specific settings matching the expectations listed

Respond ONLY with the JSON object, no other text.
"""
    return prompt


def parse_llm_response(response: str) -> dict:
    """Parse the LLM response as JSON."""
    # Try to extract JSON from the response
    response = response.strip()

    # Handle markdown code blocks
    if response.startswith("```json"):
        response = response[7:]
    if response.startswith("```"):
        response = response[3:]
    if response.endswith("```"):
        response = response[:-3]

    response = response.strip()

    try:
        return json.loads(response)
    except json.JSONDecodeError as e:
        return {
            "passed": False,
            "score": 0.0,
            "summary": "Failed to parse LLM response",
            "errors": [f"JSON parse error: {e}", f"Raw response: {response[:500]}"]
        }


def validate_example(example_dir: Path, provider: str) -> ValidationResult:
    """Validate a single example."""
    example_name = example_dir.name

    try:
        # Load expected configuration
        expected = load_expected_yaml(example_dir)
        use_case = expected.get("use_case", "Unknown")

        # Load rendered Terraform files
        rendered_files = load_rendered_tf(example_dir)

        if not rendered_files:
            return ValidationResult(
                example_name=example_name,
                use_case=use_case,
                passed=False,
                score=0.0,
                errors=["No rendered Terraform files found. Run 'terraform apply' first."]
            )

        # Build prompt and call LLM
        prompt = build_validation_prompt(expected, rendered_files)
        llm_response = call_llm(provider, prompt)

        # Parse response
        result = parse_llm_response(llm_response)

        return ValidationResult(
            example_name=example_name,
            use_case=use_case,
            passed=result.get("passed", False),
            score=result.get("score", 0.0),
            findings=result.get("warnings", []),
            errors=result.get("errors", []),
            llm_response=llm_response
        )

    except FileNotFoundError as e:
        return ValidationResult(
            example_name=example_name,
            use_case="Unknown",
            passed=False,
            score=0.0,
            errors=[str(e)]
        )
    except Exception as e:
        return ValidationResult(
            example_name=example_name,
            use_case="Unknown",
            passed=False,
            score=0.0,
            errors=[f"Unexpected error: {e}"]
        )


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
def find_examples(base_dir: Path, specific_example: Optional[str] = None) -> list[Path]:
    """Find all example directories."""
    if specific_example:
        example_path = base_dir / specific_example
        if example_path.exists():
            return [example_path]
        else:
            print(f"ERROR: Example '{specific_example}' not found")
            sys.exit(1)

    examples = []
    for d in sorted(base_dir.iterdir()):
        if d.is_dir() and d.name.startswith("account-cluster-"):
            examples.append(d)

    return examples


def main():
    parser = argparse.ArgumentParser(
        description="LLM-based validation for ACAI Account Hardening examples"
    )
    parser.add_argument(
        "--provider",
        choices=["openai", "azure"],
        default="openai",
        help="LLM provider to use (default: openai)"
    )
    parser.add_argument(
        "--example",
        type=str,
        help="Specific example to validate (e.g., account-cluster-1)"
    )
    parser.add_argument(
        "--output",
        type=str,
        default="validation-results.json",
        help="Output file for results (default: validation-results.json)"
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=0.8,
        help="Minimum score to pass (default: 0.8)"
    )
    args = parser.parse_args()

    # Find examples
    examples = find_examples(SCRIPT_DIR, args.example)
    print(f"Found {len(examples)} example(s) to validate")

    # Validate each example
    results: list[ValidationResult] = []
    for example_dir in examples:
        print(f"\nValidating {example_dir.name}...")
        result = validate_example(example_dir, args.provider)
        results.append(result)

        status = "PASS" if result.passed and result.score >= args.threshold else "FAIL"
        print(f"  [{status}] {result.use_case} - Score: {result.score:.2f}")

        if result.errors:
            for error in result.errors:
                print(f"    ERROR: {error}")
        if result.findings:
            for finding in result.findings[:3]:  # Show first 3 findings
                print(f"    Finding: {finding}")

    # Generate summary
    total = len(results)
    passed = sum(1 for r in results if r.passed and r.score >= args.threshold)
    failed = total - passed

    print(f"\n{'='*60}")
    print(f"VALIDATION SUMMARY")
    print(f"{'='*60}")
    print(f"Total:  {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"{'='*60}")

    # Write results to JSON file
    output_path = SCRIPT_DIR / args.output
    output_data = {
        "summary": {
            "total": total,
            "passed": passed,
            "failed": failed,
            "threshold": args.threshold,
            "provider": args.provider
        },
        "results": [
            {
                "example": r.example_name,
                "use_case": r.use_case,
                "passed": r.passed and r.score >= args.threshold,
                "score": r.score,
                "errors": r.errors,
                "findings": r.findings
            }
            for r in results
        ]
    }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=2)

    print(f"\nResults written to: {output_path}")

    # Exit with appropriate code
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
