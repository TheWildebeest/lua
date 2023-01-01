import { archiveFolder } from "zip-lib";

console.log("Building 'maintenance-man.love' file...")

const buildZip = () => {
  archiveFolder("./src", "./maintenance-man.love").then(function () {
  console.log("Building 'maintenance-man.love' file completed successfully.")
  console.log("Building web version using love.js...")
  }, function (err) {
    console.log(err);
  });
}

buildZip()