require "../client"

module Leyline
  struct Backstory
    include JSON::Serializable

    getter
  end

  struct BackstoryAnswer
    include JSON::Serializable

    getter id : String
    getter title : String
    getter description : String
    getter journal : String
    getter question : Int32
    getter professions : Array(String)
    getter races : Array(String)
  end

  module BackstoryAnswerIdConverter
    def self.from_json(parser : JSON::PullParser)
      answers = [] of BackStoryAnswer
      parser.read_array do
        answers << BackStoryAnswer.from_json(parser.read_raw)
      end
    end
  end

  struct BackStoryQuestion
    include JSON::Serializable

    getter id : Int32
    getter title : String
    getter description : String

    @[JSON::Field(converter: BackstoryAnswerIdConverter)]
    getter answers : Array(BackStoryAnswer)
    getter order : Int32
    getter races : Array(String)
    getter professions : Array(String)
  end

  class Client
    def answers : Array(BackStoryAnswer)
      _answers = {} of String => BackStoryAnswer
      Array(BackStoryAnswer).from_json(get("/backstory/answers", {"ids" => "all"})).each do |answer|
        _answers[answer["id"]] = answer
      end
      return _answers
    end

    def backstory : NamedTuple(questions: Hash(Int32, BackStoryQuestion)), answers: Hash(String, BackStoryAnswer))
      return {
        questions: questions,
        answers: answers
      }
    end
  end
end
