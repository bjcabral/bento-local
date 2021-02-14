#/bin/sh

projectPath=$( cd "$(dirname "../../.")"; pwd -P )
configfile="$projectPath/.env"

while IFS='=' read -r key value; do
  if [[ !( -z "${key}") ]]; then
    eval ${key}=\${value}
  fi
done < "$configfile"

if ! command -v git &> /dev/null
then
    echo "ERROR: git is not found in your path. Please install git before running the initialization script."
    exit
fi

read -p "use demo data [default=$USE_DEMO_DATA]: " user_data
  : ${user_data:=$USE_DEMO_DATA}; USE_DEMO_DATA=$user_data
read -p "set bento-backend repository [default=$BACKEND_REPO]: " user_data
  : ${user_data:=$BACKEND_REPO}; BACKEND_REPO=$user_data
read -p "set bento-backend branch [default=$BACKEND_BRANCH]: " user_data
  : ${user_data:=$BACKEND_BRANCH}; BACKEND_BRANCH=$user_data
read -p "set bento-frontend repository [default=$FRONTEND_REPO]: " user_data
  : ${user_data:=$FRONTEND_REPO}; FRONTEND_REPO=$user_data
read -p "set bento-frontend branch [default=$FRONTEND_BRANCH]: " user_data
  : ${user_data:=$FRONTEND_BRANCH}; FRONTEND_BRANCH=$user_data
read -p "set bento-model repository [default=$MODEL_REPO]: " user_data
  : ${user_data:=$MODEL_REPO}; MODEL_REPO=$user_data
read -p "set bento-model branch [default=$MODEL_BRANCH]: " user_data
  : ${user_data:=$MODEL_BRANCH}; MODEL_BRANCH=$user_data
echo ""

if [[ -d "$projectPath/$BACKEND_SOURCE_FOLDER" ]]
then
  echo "The backend repository is already initialized in:  $projectPath/$BACKEND_SOURCE_FOLDER. Please remove this folder and re-initialize the project."
  echo ""
else
  echo "Cloning bento-backend repository:  $BACKEND_BRANCH branch"
  git clone -b "$BACKEND_BRANCH" --single-branch "$BACKEND_REPO" "$projectPath/$BACKEND_SOURCE_FOLDER" &> /dev/null && echo "Created backend source folder: $projectPath/$BACKEND_SOURCE_FOLDER" || echo "ERROR CREATING BACKEND SOURCE FOLDER: $projectPath/$BACKEND_SOURCE_FOLDER - PLEASE VERIFY THAT THIS FOLDER EXISTS BEFORE BUILDING BENTO-LOCAL"
  echo ""
fi

if [[ -d "$projectPath/$FRONTEND_SOURCE_FOLDER" ]] && [[ -n "$(find $projectPath/$FRONTEND_SOURCE_FOLDER -maxdepth 1 -type f 2>/dev/null)" ]]
then
  echo "The frontend repository is already initialized in:  $projectPath/$FRONTEND_SOURCE_FOLDER. Please remove this folder and re-initialize the project."
  echo ""
else
  echo "Cloning bento-frontend repository:  $FRONTEND_BRANCH branch"
  if [[ -d "$projectPath/$FRONTEND_SOURCE_FOLDER" ]]; then rm -rf $projectPath/$FRONTEND_SOURCE_FOLDER; fi
  git clone -b "$FRONTEND_BRANCH" --single-branch "$FRONTEND_REPO" "$projectPath/$FRONTEND_SOURCE_FOLDER" &> /dev/null && echo "Created frontend source folder: $projectPath/$FRONTEND_SOURCE_FOLDER" || echo "ERROR CREATING FRONTEND SOURCE FOLDER: $projectPath/$FRONTEND_SOURCE_FOLDER - PLEASE VERIFY THAT THIS FOLDER EXISTS BEFORE BUILDING BENTO-LOCAL"
  echo ""
fi

if [[ -d "$projectPath/$BENTO_DATA_MODEL" ]]
then
  echo "The data model repository is already initialized in:  $projectPath/$BENTO_DATA_MODEL. Please remove this folder and re-initialize the project."
  echo ""
else
  echo "Cloning bento-model repository:  $MODEL_BRANCH branch"
  git clone -b "$MODEL_BRANCH" --single-branch "$MODEL_REPO" "$projectPath/$BENTO_DATA_MODEL" &> /dev/null && echo "Created model folder: $projectPath/$BENTO_DATA_MODEL" || echo "ERROR CREATING BENTO MODEL FOLDER: $projectPath/$BENTO_DATA_MODEL - PLEASE VERIFY THAT THIS FOLDER EXISTS BEFORE RUNNING THE BENTO DATALOADER"
  echo ""
fi

if [[ $USE_DEMO_DATA == "yes" ]]
then
  if [[ -d "$projectPath/data" ]]
  then
    echo "The bento-local project already has a data folder defined. Please remove this folder and re-initialize the project."
  else
    echo Seeding project with demo data
	cp -R ../demo_data "$projectPath"/data &> /dev/null && echo "Created data folder: $projectPath/data" || echo "ERROR CREATING DATA FOLDER: $projectPath\data - PLEASE VERIFY THAT THIS FOLDER EXISTS BEFORE RUNNING THE BENTO DATALOADER"
  fi
else
mkdir $projectPath/data &> /dev/null
fi