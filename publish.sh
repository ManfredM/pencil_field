# Make sure everything is formatted properly
dart format .

# run the tests before
flutter test
if [ $? -eq 0 ]; then
  echo "Flutter test run successfully."
else
  echo "Flutter test failed."
  exit 1
fi

# finally publish the package
dart pub publish

