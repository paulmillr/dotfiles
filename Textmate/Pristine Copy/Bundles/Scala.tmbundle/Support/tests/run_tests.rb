module RunTests
  
  module_function
  
  def compare(name)
    result = `./gtm < input/#{name}.scala ../../Syntaxes/Scala.tmLanguage`.split("\n")
    expected = `cat output/#{name}.output`.split("\n")

    booleans = Array.new(result.count) { |index|
      result[index] == expected[index]
    }
    booleans.uniq.count == 1 && booleans.uniq[0] == true
  end
  
end

## This tests a simple class definition
puts "Simple class: " + RunTests.compare("class").to_s

## This tests a simple method definition
puts "Simple method: " + RunTests.compare("method").to_s

## Import with brackets, ie. scala.xml.NodeSeq
puts "Simple import: " + RunTests.compare("import").to_s

## Import without brackets, ie. scala.xml.NodeSeq
puts "Simple import2: " + RunTests.compare("import2").to_s

## Comments on same line as import statements 
puts "Simple import3: " + RunTests.compare("import3").to_s

## In identifiers $ and _ should be treated as uppercase letters
## are be allowed. 
puts "Identifiers: " + RunTests.compare("identifiers").to_s