
function InitWorkspace() {
  cd /projects
  for i in disaster mission shelter
  do
    ./code-assistant-sandbox/scripts/bootstrap --create -a=${i} -g=org.cajun_navy --base
  done
}

function ResetWorkspace() {
  cd /projects
  rm -rf disaster mission shelter
  InitWorkspace
}

for i in "$@"
do
  case $i in
    --init)
      InitWorkspace "$@"
    ;;
    --reset)
      ResetWorkspace "$@"
    ;;
  esac
done