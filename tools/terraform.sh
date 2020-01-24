if command -v  terraform > /dev/null; then
  alias tf_apply='terraform apply -auto-approve'
fi