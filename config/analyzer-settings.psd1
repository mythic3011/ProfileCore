# PSScriptAnalyzer Settings for ProfileCore
# https://github.com/PowerShell/PSScriptAnalyzer

@{
    # Severity levels to include
    Severity = @('Error', 'Warning', 'Information')

    # Exclude specific rules
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',  # We use Write-Host for colored output intentionally
        'PSAlignAssignmentStatement',  # Alignment is enforced by editor, not critical
        'PSAvoidGlobalVars',  # We use global:ProfileCore intentionally for state management
        'PSUseShouldProcessForStateChangingFunctions',  # Not all state-changing functions need ShouldProcess
        'PSUseSingularNouns',  # Some plural nouns are intentional (Get-*s makes sense)
        'PSUseConsistentWhitespace'  # Let formatter handle this
    )

    # Include specific rules
    IncludeRules = @(
        'PSUseApprovedVerbs',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidGlobalVars',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSAlignAssignmentStatement',
        'PSUseCorrectCasing'
    )

    # Rule configurations
    Rules = @{
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }

        PSAlignAssignmentStatement = @{
            Enable = $false  # Disabled - let editor handle alignment
        }

        PSUseCorrectCasing = @{
            Enable = $true
        }

        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $false
        }

        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $false
            BlockComment = $true
            VSCodeSnippetCorrection = $true
            Placement = 'before'
        }
    }
}

