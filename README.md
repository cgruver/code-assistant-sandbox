# code-assistant-sandbox
Sandbox project for experimenting with privately hosted code assistants.

```bash
cd /projects
for i in disaster mission shelter
do
  ./code-assistant-sandbox/bootstrap --create -a=${i} -g=org.cajun_navy --base
  ln -s ${i} /projects/code-assistant-sandbox/${i}
done

