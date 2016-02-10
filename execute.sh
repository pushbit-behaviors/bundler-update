#!/bin/bash -l

#installed
echo installed ruby versions
rvm list

#known
echo known ruby versions
rvm list known

echo "Entering code directory"
cd code

echo "Caching Gemfile.lock"
cp Gemfile.lock Gemfile.lock.old
if [ $? -eq 0 ]
then
  echo "Gemfile.lock cached"
else
  echo "No Gemfile.lock found"
  exit 0
fi

echo "Using ruby version"
ruby --version

echo "Installing required gems"
gem install bundler
gem install faraday

echo "Checking out new branch"
git checkout -B pushbit/bundler-update

export COMMIT="$(git rev-parse HEAD)"

echo "Updating bundle"
bundle update

git add Gemfile.lock

if git diff-index --quiet HEAD --; then
  echo "Bundle was not updated"
else
  echo "Bundle was updated"
  git commit -m "bundle updated"
  git push -f origin pushbit/bundler-update

  ruby ../execute.rb
fi