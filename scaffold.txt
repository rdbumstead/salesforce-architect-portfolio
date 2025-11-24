# scaffold-with-gitignore.ps1
# Run in PowerShell from your repo root

$ErrorActionPreference = "Stop"

Write-Host "🚀 Creating Salesforce Portfolio scaffold..." -ForegroundColor Cyan

# --- Helper Functions ---
function Create-Dir {
    param ($Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
        Write-Host "  [+] Created dir:  $Path" -ForegroundColor Gray
    }
}

function Create-File {
    param ($Path, $Content = "")
    if (-not (Test-Path $Path)) {
        New-Item -ItemType File -Force -Path $Path | Out-Null
        if ($Content) { Set-Content -Path $Path -Value $Content }
        Write-Host "  [+] Created file: $Path" -ForegroundColor Gray
    } else {
        Write-Host "  [.] Exists: $Path" -ForegroundColor DarkGray
    }
}

# --- 1. Create Directory Structure ---
Create-Dir ".github\workflows"
Create-Dir "scripts\org-setup"
Create-Dir "scripts\data-seed"
Create-Dir "scripts\build"
Create-Dir "docs\c4"
Create-Dir "docs\architecture-decision-records"
Create-Dir "docs\sas"
Create-Dir "docs\oas"
Create-Dir "integration-architecture\process-api"
Create-Dir "integration-architecture\experience-api"
Create-Dir "integration-architecture\mulesoft"

# Package Directories
$packages = @(
    "packages\portfolio-core\force-app\main\default\lwc",
    "packages\portfolio-core\force-app\main\default\classes",
    "packages\portfolio-core\force-app\main\default\objects\Testimonial__c",
    "packages\portfolio-core\force-app\main\default\objects\Project__c",
    "packages\portfolio-core\force-app\main\default\objects\Skill__c",
    "packages\portfolio-core\force-app\main\default\objects\Project_Skill__c",
    "packages\portfolio-core\force-app\main\default\sites",
    "packages\portfolio-core\force-app\main\default\agentforce",
    "packages\demo-mcc-hub\force-app\main\default\objects",
    "packages\demo-mcc-hub\force-app\main\default\flows",
    "packages\demo-mcc-hub\force-app\main\default\dashboards",
    "packages\demo-mcc-hub\docs",
    "packages\api-work-experience\force-app\main\default\classes",
    "packages\api-work-experience\force-app\main\default\customMetadata",
    "packages\future-modules\multi-cloud-aws",
    "packages\future-modules\process-apis"
)
foreach ($p in $packages) { Create-Dir $p }

# LWC Component Folders
$lwcs = "c-hero-banner","c-resume-builder","c-skill-network","c-api-tester","c-changelog","c-testimonial-submit"
foreach ($lwc in $lwcs) {
    $lwcPath = "packages\portfolio-core\force-app\main\default\lwc\$lwc"
    Create-Dir $lwcPath
    
    # Create basic LWC files to avoid empty folder issues
    Create-File "$lwcPath\$lwc.js" "import { LightningElement } from 'lwc'; export default class $lwc extends LightningElement {}"
    Create-File "$lwcPath\$lwc.html" "<template><!-- $lwc --></template>"
    Create-File "$lwcPath\$lwc.js-meta.xml" "<?xml version='1.0' encoding='UTF-8'?><LightningComponentBundle xmlns='http://soap.sforce.com/2006/04/metadata'><apiVersion>60.0</apiVersion><isExposed>true</isExposed></LightningComponentBundle>"
}

# --- 2. Create Configuration Files ---
Create-File ".github\CODEOWNERS" "# @ryanbumstead"
Create-File "docs\sas.md" "# Systems Architecture Specification"
Create-File "docs\roadmap.md" "# Implementation Roadmap"
Create-File "integration-architecture\salesforce-sapi.yaml" "openapi: 3.0.0`ninfo:`n  title: Work Experience API`n  version: 1.0.0"

# --- 3. Root sfdx-project.json ---
# Note: Using a single root config is best practice for multi-package repos.
$rootJson = @{
    "packageDirectories" = @(
        @{ "path" = "packages/portfolio-core"; "default" = $true; "package" = "Portfolio-Core"; "versionName" = "ver 1.0"; "versionNumber" = "1.0.0.NEXT" },
        @{ "path" = "packages/demo-mcc-hub"; "package" = "MCC-Hub-Demo"; "versionName" = "ver 1.0"; "versionNumber" = "1.0.0.NEXT"; "dependencies" = @(@{ "package" = "Portfolio-Core" }) },
        @{ "path" = "packages/api-work-experience"; "package" = "Integration-API"; "versionName" = "ver 1.0"; "versionNumber" = "1.0.0.NEXT"; "dependencies" = @(@{ "package" = "Portfolio-Core" }) }
    )
    "namespace" = ""
    "sfdcLoginUrl" = "https://login.salesforce.com"
    "sourceApiVersion" = "60.0"
    "packageAliases" = @{}
}
$rootJsonContent = $rootJson | ConvertTo-Json -Depth 10
Create-File "sfdx-project.json" $rootJsonContent

# --- 4. .forceignore ---
$forceIgnore = @"
.sfdx
.sf
.vscode
.git
package.json
**/*.pptx
**/*.pdf
**/*.docx
integration-architecture/**
scripts/**
.github/**
"@
Create-File ".forceignore" $forceIgnore

# --- 5. .gitignore (Full Content) ---
$gitignoreContent = @"
# ---------------------------------------------------------------------
# Salesforce DX & CLI
# ---------------------------------------------------------------------
# SFDX configuration and state folders
.sfdx/
.sf/
**/.sfdx
**/.sf

# Metadata retrieve/deploy temp folders & local auth
.deploys/
.retrieves/
.sfdx-aut*

# Org shape exports (backups)
config/project-scratch-def.json.bak

# Local CLI configuration
sfdx-config.json
.localdevserver

# LWC / Apex Language Server typings (auto-generated)
.vscode/sfdx/
typings/
**/typings/

# Code Scanner / PMD Cache
.pmdCache/
.scannerwork/

# ---------------------------------------------------------------------
# Node.js / JavaScript / LWC
# ---------------------------------------------------------------------
# Dependencies
node_modules/
**/node_modules/

# Jest / Testing / Apex Tests
coverage/
**/coverage/
junit/
test-result/
**/test-result/
test-results/
**/test-results/

# Linting & Formatting Caches
.eslintcache
.prettier-cache/

# Debug logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# ---------------------------------------------------------------------
# Security & Secrets (CRITICAL)
# ---------------------------------------------------------------------
# Environment variables
.env
.env.local
.env.development
.env.staging
.env.production

# Private keys and certificates (never commit these)
server.key
assets/server.key
*.key
*.p12
*.pem

# ---------------------------------------------------------------------
# OS & IDE Junk
# ---------------------------------------------------------------------
# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Visual Studio Code
# Ignore user state, BUT preserve team-shared configs:
.vscode/*
!.vscode/settings.json      # Shared Prettier/ESLint rules
!.vscode/tasks.json         # Shared build tasks
!.vscode/launch.json        # Shared debug configurations
!.vscode/extensions.json    # Recommended extensions
*.code-workspace

# IntelliJ / WebStorm
.idea/
*.iml

# ---------------------------------------------------------------------
# Documentation & Binary Artifacts
# ---------------------------------------------------------------------
# BEST PRACTICE: Ignore binary/generated documents to prevent repo bloat.
*.pdf
*.docx
*.doc
*.pptx
*.ppt
*.xlsx
*.xls

# Temporary lock files
~$*.doc*
~$*.ppt*
~$*.xls*

# EXCEPTION: Explicitly allow the Architecture Spec for the portfolio
!docs/architecture-spec.pdf
!docs/architecture.pdf

# ---------------------------------------------------------------------
# CI/CD & Build Artifacts
# ---------------------------------------------------------------------
# General Build Artifacts
dist/
build/
.tmp/
.temp/
.cache/

# GitHub Actions local testing (if using 'act')
.act/
.github/workflows/.act/

# Salesforce Deployment Artifacts
.deploy/
deploy/deploy-packages/

# ---------------------------------------------------------------------
# Local Integration Testing & AWS (Phase 8)
# ---------------------------------------------------------------------
# Mock API responses & Local Test Data
**/mocks/responses/*.json.local
**/test-data/*.local.json
postman_collection.local.json

# AWS Lambda / Serverless
.aws-sam/
samconfig.toml.local
lambda-layer-*.zip
function-*.zip
*.tfstate
*.tfstate.backup
.terraform/
"@

# Force creation/overwrite of .gitignore with the exact content
Set-Content -Path ".gitignore" -Value $gitignoreContent -Force
Write-Host "  [+] Created file: .gitignore" -ForegroundColor Gray

Write-Host "`n✅ Scaffold created successfully!" -ForegroundColor Green