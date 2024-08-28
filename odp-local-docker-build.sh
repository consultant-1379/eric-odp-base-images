#!/bin/bash
export ISO_VERSION=0.0.0
current_folder_name=$(basename "$PWD")

build_context=.
image_name=${current_folder_name}

if [[ $1 = "base" ]]; then
   image_name=eric-odp-sles-base
elif [ $1 = "main" ]; then
   image_name=eric-odp-main-container
elif [ $1 = "init" ]; then
   image_name=eric-odp-init
else
   echo "Choose which image to build: base, main or init"
   exit 0
fi

build_context=.

echo ${build_context} ${image_name}
image_path=armdocker.rnd.ericsson.se/proj_oss_releases/enm/${image_name}

git tag | grep "$(cat VERSION_PREFIX)-" &> /dev/null

if [ $? -gt 0 ]; then
  export image_version="$(cat VERSION_PREFIX)-1"
else
  export image_version=$(git tag | grep "$(cat VERSION_PREFIX)-" | sort --version-sort --field-separator=- --key=2,2 | tail -n1)-zpiakar
fi

export image_version=1.1.0-1-zpiakar
export image_version_base=1.1.0-1
docker build --force-rm --build-arg IMAGE_BUILD_VERSION=$image_version_base -f ${build_context}/Dockerfile -t "$image_path:$image_version" --target $image_name ${build_context}

STATUS=$?

exit 0

if [ $STATUS -eq 0 ]; then
   echo "Pushing image to remote registry."
   IMAGE_ID=$(cat image_id)
   time docker push "$image_path:$image_version"
   #docker rm "$image_path:latest"
fi



exit 0

