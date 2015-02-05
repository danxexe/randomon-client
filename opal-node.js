var fs, parser, parserFile, source, sourceFile, vm;

sourceFile = "" + __dirname + "/js/vendor/opal.js";
// parserFile = "" + __dirname + "/node_modules/opal/opal/opal-parser.js";

fs = require('fs');
vm = require('vm');

source = fs.readFileSync(sourceFile).toString();
// parser = fs.readFileSync(parserFile).toString();

vm.runInThisContext(source, sourceFile);
vm.runInThisContext(parser, parserFile);

Opal.compile = function(ruby, options) {
  var compiler = this.Opal.Compiler.$new();
  compiler.source = ruby;
  var source = compiler.$compile();
  var out = "";
  var required = "";

  var requires = compiler.$requires();

  for (var i = 0; i < requires.length; i++) {
    try {
      required_source = fs.readFileSync("" + __dirname + "/js/opal/" + requires[i] + ".rb").toString();
      compiler.source = required_source;
      required = compiler.$compile();
      out += required;
    } catch (e) {
    }
  }
  return out + source;
}

module.exports = Opal;
