install_node_modules() {
  echo "working with branch $BRANCH"
  yarn install
}

execute_tests_and_code_coverage() { # TODO edit it for our monorepo
  echo "testing service $1"
  yarn workspace $1 test
 
}

tag_and_push_image() {
  ACCOUNT_NAME='316425403378.dkr.ecr.eu-west-1.amazonaws.com'

  echo "working with branch $BRANCH"

  echo "building image" $1"_feature"
  sudo docker build -t $ACCOUNT_NAME/$1"_feature":$BRANCH.$SHIPPABLE_BUILD_NUMBER -f packages/$1/Dockerfile .
  echo "pushing image" $1"_feature"
  sudo docker push $ACCOUNT_NAME/$1"_feature":$BRANCH.$SHIPPABLE_BUILD_NUMBER

  # We trigger the manifest and subsequently the deploy jobs downstream by posting a new version to the image resource.
  # Since the image resource is an INPUT to the manifest job, the manifest job will get scheduled to run after these steps.
  # NV : repository name should match ECR name
  echo "posting the version of the image resource for $1"
  shipctl put_resource_state $1"_img_feature" "SHIPPABLE_BUILD_NUMBER" $SHIPPABLE_BUILD_NUMBER
  shipctl put_resource_state $1"_img_feature" "versionName" $BRANCH.$SHIPPABLE_BUILD_NUMBER
}

main() {
	install_node_modules
	tag_and_push_image "$@"
}

main "$@"
