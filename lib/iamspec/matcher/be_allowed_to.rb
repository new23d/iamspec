require_relative 'generic_allowed_to.rb'

def be_allowed_to(action)
  BeAllowedTo.new(action)
end

class BeAllowedTo < GenericAllowedTo
  def initialize(action)
    @action = action
  end

  def matches?(subject)
    @evaluation_results = super(subject)
    failure_results(@evaluation_results).empty?
  end

  def description
    "be allowed to #{@action.to_s} #{@action.userid ? 'with userid ' + @action.userid : ''}"
  end

  def failure_message
    "wasn't allowed because of #{failure_strings(@evaluation_results)}"
  end

  def expected
    @evaluation_results.map {|result| "#{result.eval_action_name} is allowed"}.join("\n")
  end

  def actual
    @evaluation_results.map {|result| "#{result.eval_action_name} is #{result.eval_decision}"}.join("\n")
  end

  def diffable?
    true
  end

  private

  def failure_strings(results)
    failure_results(results)
        .map { |result| "#{result.eval_decision} for #{result.eval_action_name}"}
        .join(' and ')
  end

  def failure_results(results)
    results.select {|result| result.eval_decision != 'allowed'}
  end

end
