#!/bin/bash -e

detect_changed_services() {
  echo "----------------------------------------------"
  echo "detecting changed folders for this commit"

  # get a list of all the changed folders only
  changed_folders=`git diff --name-only $SHIPPABLE_COMMIT_RANGE | grep packages/ | awk 'BEGIN {FS="/"} {print $2}' | uniq`
  echo "changed folders "$changed_folders

  changed_services=()
  for folder in $changed_folders
  do
    if [ "$folder" == 'common' ]; then
      echo "common folder changed, building and publishing all services"
      changed_services=("alice", "bob")
      echo "list of applications "$changed_services
      break
    else
      echo "Adding $folder to list of services to build"
      changed_services+=("$folder")
    fi
  done

  # Iterate on each service and run the packaging script
  for service in $changed_services
  do
      echo "-------------------Running packaging for $service---------------------"
      # copy the common code to the service so that it can be packaged in the docker image
      pushd packages/"$service" #what is the purpose?
      # move the build script to the root of the service
      # cp ../../package-service.sh ./.
      ls
      chmod +x ../../package-service.sh
      cd ../..
      sh package-service.sh "$service"
      popd
  done
}

detect_changed_services