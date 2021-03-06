require "jarvis/clamp_delegate"

describe Jarvis::ClampDelegate do
  let(:clamp) do
    Class.new(Clamp::Command) do
      option "--bar", :flag, "Set bar"
      def execute; end
    end
  end

  describe "#delegate" do
    it "should return a proc" do
      expect(described_class.delegate(clamp, {})).to be_a(Proc)
    end
  end

  context "when the delegate is called" do
    let(:request) { double() }
    let(:message) { double() }
    let(:delegate) { described_class.delegate(clamp, {}) }

    before do
      allow(request).to receive(:message).and_return(message)
      allow(message).to receive(:body).and_return(command_line_text)
    end

    context "with valid arguments" do
      let(:command_line_text) { "foo --bar" }
      it "should succeed" do
        delegate.call(request)
      end
    end

    context "with an invalid flag" do
      let(:command_line_text) { "foo --invalid-flag" }
      it "should reply with a failure message" do
        expect(request).to receive(:reply).with(/Unrecognised option '--invalid-flag'/)
        delegate.call(request)
      end
    end

    context "with an invalid parameter" do
      let(:command_line_text) { "foo param1" }
      it "should reply with a failure message" do
        expect(request).to receive(:reply).with(/^Error: too many arguments/)
        delegate.call(request)
      end
    end

    context "and :flags are given to clamp_delegate" do
      let(:clamp) do
        Class.new(Clamp::Command) do
          option "--bar", :flag, "Set bar"
          option "--name", "NAME", "The name"
          def execute; end
        end
      end

      let(:delegate) { described_class.delegate(clamp, flags: flags) }
      let(:command_line_text) { "" }

      context "with an invalid flag" do
        let(:flags) do
          { "--invalid-flag" => ->(_) { "example" } }
        end
        it "should fail" do
          expect(request).to receive(:reply).with(/Unrecognised option '--invalid-flag'/)
          delegate.call(request)
        end
      end

      context "with a valid flag" do
        let(:flags) do
          { "--name" => ->(_) { "Jordan" } }
        end
        it "should succeed" do
          delegate.call(request)
        end
      end
    end
  end
end
