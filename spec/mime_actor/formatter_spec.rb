# frozen_string_literal: true

require "mime_actor"

RSpec.describe MimeActor::Formatter do
  let(:klazz) { Class.new.include described_class }
  
  describe "#act_on_format" do
    subject(:act) { klazz.act_on_format(*params) }

    let(:params) { Array.wrap(formats) + [actions] }
    let(:formats) { :xml }
    let(:actions) { { on: :index } }

    context "with single format and single action" do
      let(:formats) { :html }
      let(:actions) { { on: :create } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include("create" => Set[:html])
      end
    end

    context "with multiple formats and single action" do
      let(:formats) { [:html, :json] }
      let(:actions) { { on: :create } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include("create" => Set[:html, :json])
      end
    end

    context "with single format and multiple actions" do
      let(:formats) { :html }
      let(:actions) { { on: [:index, :create] } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html], 
          "create" => Set[:html] 
        })
      end
    end

    context "with multiple formats and multiple actions" do
      let(:formats) { [:html, :json, :xml] }
      let(:actions) { { on: [:index, :create, :update] } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html, :json, :xml],
          "create" => Set[:html, :json, :xml],
          "update" => Set[:html, :json, :xml] 
        })
      end
    end

    context "with multiple times calls" do
      it "merges mappings in class attributes" do
        expect(klazz.action_formatters).to be_empty
        klazz.act_on_format(:html, on: [:index, :create])
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html],
          "create" => Set[:html]
        })
        klazz.act_on_format(:xml, on: [:create, :update])
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html],
          "create" => Set[:html, :xml],
          "update" => Set[:xml]
        })
        klazz.act_on_format(:json, :xml, on: [:create, :show])
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html],
          "create" => Set[:html, :xml, :json],
          "update" => Set[:xml],
          "show" => Set[:json, :xml]
        })
      end
    end
  end
end