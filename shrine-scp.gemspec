# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "shrine-scp"
  spec.version       = "0.1.0"
  spec.authors       = ["jordanandree"]
  spec.email         = ["jordanandree@gmail.com"]

  spec.summary       = %q{Scp storage for Shrine file attachment toolkit}
  spec.homepage      = "https://github.com/jordanandree/shrine-scp"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "shrine", ">= 2.0"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
