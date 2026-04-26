# Disable file completions — craft.sh takes text input, not file paths
complete -c craft.sh -f

complete -c craft.sh -s h -l help    -d 'Show help and exit'
complete -c craft.sh -s d -l debug   -d 'Enable debug logging'
complete -c craft.sh      -l dry-run -d 'Display JSON payload without sending to API'

complete -c craft.sh -l date -r -d 'Target date for content' \
    -a 'today\t"Today" tomorrow\t"Tomorrow" yesterday\t"Yesterday"'

complete -c craft.sh -l due -r -d 'Due date for tasks (YYYY-MM-DD)' \
    -a 'today\t"Today" tomorrow\t"Tomorrow" yesterday\t"Yesterday"'

complete -c craft.sh -l language -r -d 'Code block language' \
    -a 'bash\t"Bash" python\t"Python" javascript\t"JavaScript" typescript\t"TypeScript" json\t"JSON" yaml\t"YAML" sql\t"SQL" go\t"Go" rust\t"Rust" c\t"C" cpp\t"C++" java\t"Java" kotlin\t"Kotlin" swift\t"Swift" php\t"PHP" ruby\t"Ruby"'

complete -c craft.sh -s c -l code -d 'Wrap input in a code block'
complete -c craft.sh -s t -l task -d 'Format input as a task list'
complete -c craft.sh -s l -l list -d 'Format input as a bullet list'
