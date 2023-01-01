import { archiveFolder } from "zip-lib";

console.time("Built in ")
console.log("Building...")
archiveFolder("./src", "./dist/maintenance-man.love").then(function () {
console.log("Construction complete.")
  console.timeEnd("Built in ")
}, function (err) {
  console.log(err);
});