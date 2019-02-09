require "spec"
require "../src/leyline"
require "webmock"

Spec.before_each &->WebMock.reset
