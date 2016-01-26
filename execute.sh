#!/bin/bash -l

#installed
echo installed ruby versions
rvm list

#known
echo known ruby versions
rvm list known

echo "entering git repo"
cd code

echo "cache current Gemfile.lock"
cp Gemfile.lock Gemfile.lock.old
if [ $? -eq 0 ]
then
  echo "Gemfile.lock cached"
else
  echo "No Gemfile.lock"
  exit 0
fi

echo "using ruby version"
ruby --version

echo "ensure bundler"
gem install bundler
gem install faraday

echo "checking out new branch"
git checkout -B pushbit/bundler-update

export COMMIT="$(git rev-parse HEAD)"

echo "manipulating source code"
bundle update

git add Gemfile.lock

if git diff-index --quiet HEAD --; then
  echo "your bundle was not updated"
else
  echo "your bundle was updated"
  echo "commiting"
  git commit -m "bundle updated"

  echo "pushing source code"
  git push -f origin pushbit/bundler-update

  ruby ../execute.rb
fi
