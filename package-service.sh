install_node_modules() {
    npm install
}

execute_tests_and_code_coverage() { # TODO edit it for our monorepo
  if [ -f ./Gruntfile.js ]; then
    grunt --force
    ./node_modules/.bin/istanbul cover grunt --force --dir $SHIPPABLE_BUILD_DIR/shippable/codecoverage
    ./node_modules/.bin/istanbul report cobertura --dir  $SHIPPABLE_BUILD_DIR/shippable/codecoverage/
  fi  
}

tag_and_push_image() {
  ACCOUNT_NAME='316425403378.dkr.ecr.eu-west-1.amazonaws.com'

  echo "building image $1"
  sudo docker build -t $ACCOUNT_NAME/$1:$BRANCH.$SHIPPABLE_BUILD_NUMBER -f packages/$1/Dockerfile .
  echo "pushing image $1"
  sudo docker push $ACCOUNT_NAME/$1:$BRANCH.$SHIPPABLE_BUILD_NUMBER

  # We trigger the manifest and subsequently the deploy jobs downstream by posting a new version to the image resource.
  # Since the image resource is an INPUT to the manifest job, the manifest job will get scheduled to run after these steps.
  # NV : repository name should match ECR name
  echo "posting the version of the image resource for $1"
  shipctl put_resource_state $1"_img" "SHIPPABLE_BUILD_NUMBER" $SHIPPABLE_BUILD_NUMBER
  shipctl put_resource_state $1"_img" "versionName" $BRANCH.$SHIPPABLE_BUILD_NUMBER
}

main() {
	install_node_modules
	tag_and_push_image "$@"
}

main "$@"
