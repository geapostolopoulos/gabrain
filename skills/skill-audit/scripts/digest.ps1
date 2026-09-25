param(
    [Parameter(Mandatory = $true)][string]$SessionId,
    [int]$Show = 0
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$root = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $HOME '.copilot' }
$file = Join-Path $root "session-state\$SessionId\events.jsonl"
if (-not (Test-Path $file)) { throw "No events.jsonl for session $SessionId at $file" }

$events = New-Object System.Collections.Generic.List[object]
$unparsed = 0
foreach ($line in [IO.File]::ReadLines($file)) {
    if (-not $line.Trim()) { continue }
    try { $events.Add(($line | ConvertFrom-Json)) } catch { $unparsed++ }
}

function Clip([string]$text, [int]$max) {
    $flat = ($text -replace '\s+', ' ').Trim()
    if ($flat.Length -gt $max) { $flat.Substring(0, $max) + '...' } else { $flat }
}

$main = @($events | Where-Object { -not $_.agentId })
$mainCalls = @($main | Where-Object type -eq 'tool.execution_start')
$completes = @{}
foreach ($e in $events) {
    if ($e.type -eq 'tool.execution_complete') { $completes[$e.data.toolCallId] = $e.data }
}

if ($Show -gt 0) {
    if ($Show -gt $mainCalls.Count) { throw "Call #$Show does not exist; there are $($mainCalls.Count) main-agent calls." }
    $mainCalls[$Show - 1].data.arguments | ConvertTo-Json -Depth 10
    exit 0
}

$start = $events | Where-Object type -eq 'session.start' | Select-Object -First 1
$usage = $events | Where-Object type -eq 'session.usage_checkpoint' | Select-Object -Last 1
$models = ($main | Where-Object { $_.type -eq 'assistant.message' -and $_.data.model } | ForEach-Object { $_.data.model } | Select-Object -Unique) -join ', '

'## Session'
"cwd: $($start.data.context.cwd) | models: $models | premium requests: $($usage.data.totalPremiumRequests) | unparsed lines: $unparsed"
''
'## Timeline (main agent only; subagent calls are excluded)'
$n = 0
foreach ($e in $main) {
    switch ($e.type) {
        'user.message' { "USER: $(Clip $e.data.content 300)" }
        'skill.invoked' { "SKILL INVOKED: $($e.data.name) ($($e.data.trigger))" }
        'assistant.message' { if ($e.data.content) { "ASSISTANT: $(Clip $e.data.content 200)" } }
        'tool.execution_start' {
            $n++
            $d = $e.data
            $a = $d.arguments
            $summary = if ($d.toolName -eq 'task') {
                "task agent_type=$($a.agent_type) name=$($a.name) mode=$($a.mode) model=$($a.model) promptChars=$("$($a.prompt)".Length)"
            } else {
                "$($d.toolName) $(Clip ($a | ConvertTo-Json -Compress -Depth 5) 110)"
            }
            $result = $completes[$d.toolCallId]
            $failed = if ($result -and $result.success -eq $false) { " [FAILED: $(Clip "$($result.error.message)" 80)]" } else { '' }
            "#$n $summary$failed"
        }
    }
}
''
'## Subagents'
$subs = @($events | Where-Object { $_.type -like 'subagent.*' -and $_.type -notin @('subagent.started', 'subagent.configured', 'subagent.selected') })
if (-not $subs) { 'none' }
foreach ($s in $subs) {
    $d = $s.data
    if ($s.type -eq 'subagent.completed') {
        "$($d.agentDisplayName) | $($d.agentName) | $($d.model) | calls $($d.totalToolCalls) | tokens $($d.totalTokens) | $([math]::Round($d.durationMs / 1000))s"
    } else {
        "$($s.type): $($d.agentDisplayName)"
    }
}

foreach ($skill in @($main | Where-Object type -eq 'skill.invoked')) {
    $dir = Split-Path $skill.data.path -Parent
    ''
    "## Skill as run: $($skill.data.name)"
    $skill.data.content
    foreach ($call in $mainCalls) {
        $path = "$($call.data.arguments.path)"
        if ($call.data.toolName -eq 'view' -and $path.StartsWith($dir, [StringComparison]::OrdinalIgnoreCase) -and $completes[$call.data.toolCallId]) {
            ''
            "### Reference as read: $($path.Substring($dir.Length).TrimStart('\'))"
            $completes[$call.data.toolCallId].result.content
        }
    }
}

''
'## Final answer'
$last = $main | Where-Object { $_.type -eq 'assistant.message' -and $_.data.content } | Select-Object -Last 1
if ($last) {
    $text = "$($last.data.content)"
    if ($text.Length -gt 3000) { $text.Substring(0, 3000) + '...' } else { $text }
} else { 'none' }
