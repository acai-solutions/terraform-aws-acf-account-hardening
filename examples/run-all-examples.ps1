# Run terraform init and apply for all account-cluster examples
# Then clean up Terraform state files
# Outputs JSON summary for Terratest evaluation

$ErrorActionPreference = "Continue"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get all account-cluster directories
$examples = Get-ChildItem -Path $scriptDir -Directory | Where-Object { $_.Name -like "account-cluster-*" } | Sort-Object Name

Write-Host "Found $($examples.Count) examples to process" -ForegroundColor Cyan

# Initialize results tracking
$results = @{
    timestamp = (Get-Date -Format "o")
    total_examples = $examples.Count
    passed = 0
    failed = 0
    examples = @()
}

foreach ($example in $examples) {
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "Processing: $($example.Name)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    
    $exampleResult = @{
        name = $example.Name
        path = $example.FullName
        init_success = $false
        apply_success = $false
        validate_success = $false
        rendered_tf_exists = $false
        error = $null
        duration_seconds = 0
    }
    
    $startTime = Get-Date
    
    Push-Location $example.FullName
    try {
        # Run terraform init
        Write-Host "Running terraform init..." -ForegroundColor Green
        terraform init -input=false 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "terraform init failed" }
        $exampleResult.init_success = $true
        
        # Run terraform apply
        Write-Host "Running terraform apply..." -ForegroundColor Green
        terraform apply -auto-approve -input=false 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "terraform apply failed" }
        $exampleResult.apply_success = $true
        
        # Validate rendered-tf output
        $renderedTfPath = Join-Path $example.FullName "rendered-tf"
        if (Test-Path $renderedTfPath) {
            $exampleResult.rendered_tf_exists = $true
            Write-Host "Validating rendered-tf output..." -ForegroundColor Green
            Push-Location $renderedTfPath
            try {
                terraform init -backend=false -input=false 2>&1 | Out-Null
                $validateOutput = terraform validate 2>&1
                if ($LASTEXITCODE -ne 0) { throw "terraform validate failed for rendered-tf: $validateOutput" }
                $exampleResult.validate_success = $true
            }
            finally {
                Pop-Location
            }
        }
        
        Write-Host "Successfully completed: $($example.Name)" -ForegroundColor Green
        $results.passed++
    }
    catch {
        Write-Host "ERROR in $($example.Name): $_" -ForegroundColor Red
        $exampleResult.error = $_.ToString()
        $results.failed++
    }
    finally {
        Pop-Location
        $exampleResult.duration_seconds = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)
        $results.examples += $exampleResult
    }
}

# Cleanup phase
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Cleaning up Terraform files..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($example in $examples) {
    Write-Host "Cleaning: $($example.Name)" -ForegroundColor Gray
    
    # Files/folders to delete in example root
    $itemsToDelete = @(
        ".terraform",
        "terraform.tfstate",
        "terraform.tfstate.backup",
        ".terraform.lock.hcl"
    )
    
    foreach ($item in $itemsToDelete) {
        $path = Join-Path $example.FullName $item
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
            Write-Host "  Deleted: $item" -ForegroundColor DarkGray
        }
    }
    
    # Also clean up rendered-tf folder
    $renderedTfPath = Join-Path $example.FullName "rendered-tf"
    if (Test-Path $renderedTfPath) {
        foreach ($item in $itemsToDelete) {
            $path = Join-Path $renderedTfPath $item
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force
                Write-Host "  Deleted: rendered-tf/$item" -ForegroundColor DarkGray
            }
        }
    }
}

# Generate summary
$results.success = ($results.failed -eq 0)
$results.pass_rate = [math]::Round(($results.passed / $results.total_examples) * 100, 2)

# Output summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total:  $($results.total_examples)" -ForegroundColor White
Write-Host "Passed: $($results.passed)" -ForegroundColor Green
Write-Host "Failed: $($results.failed)" -ForegroundColor $(if ($results.failed -gt 0) { "Red" } else { "Green" })
Write-Host "Pass Rate: $($results.pass_rate)%" -ForegroundColor White

# Write JSON summary for Terratest
$jsonPath = Join-Path $scriptDir "test-results.json"
$results | ConvertTo-Json -Depth 4 | Out-File -FilePath $jsonPath -Encoding utf8
Write-Host "`nJSON summary written to: $jsonPath" -ForegroundColor Gray

# Exit with appropriate code for CI/CD
if ($results.failed -gt 0) {
    Write-Host "`nTEST FAILED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nTEST PASSED" -ForegroundColor Green
    exit 0
}
