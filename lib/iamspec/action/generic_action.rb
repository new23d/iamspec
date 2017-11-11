module Iamspec::Action
  def perform_action(action_name, resource_arns = [])
    GenericAction.new([action_name], nil, resource_arns)
  end

  def perform_action_with_caller_arn(action_name, caller_arn, resource_arns = [])
    GenericAction.new([action_name], caller_arn, resource_arns)
  end

  def perform_actions(action_names, resource_arns = [])
    GenericAction.new(action_names, nil, resource_arns)
  end

  class GenericAction
    attr_reader :action_names
    attr_reader :caller_arn
    attr_reader :resource_arns
    attr_reader :creds
    attr_reader :policy_string
    attr_reader :policy
    attr_reader :userid
    attr_reader :sourcevpce
    attr_reader :sourceip
    attr_reader :context_entries

    def initialize(action_names, caller_arn, resource_arns)
      @caller_arn = caller_arn
      @action_names = action_names
      @resource_arns = resource_arns
      @context_entries = {}
    end

    def to_s
      if @resource_arns.empty?
        action_names.join(',')
      else
        "#{action_names.join(',')} on #{resource_arns.join(',')}"
      end
    end

    def with_credentials(creds)
      @creds = creds
      self
    end

    def with_resource(resource_arn)
      @resource_arns = [resource_arn]
      self
    end

    def with_policy(policy)
      @policy = policy
      self
    end

    def with_userid(userid)
      @userid = userid
      @context_entries[:userid] = Aws::IAM::Types::ContextEntry.new({context_key_name: "aws:userid", context_key_values: [userid], context_key_type: "string"})
      self
    end

    def with_sourcevpce(sourcevpce)
      @sourcevpce = sourcevpce
      @context_entries[:sourcevpce] = Aws::IAM::Types::ContextEntry.new({context_key_name: "aws:sourceVpce", context_key_values: [sourcevpce], context_key_type: "string"})
      self
    end

    def with_sourceip(sourceip)
      @sourceip = sourceip
      @context_entries[:sourceip] = Aws::IAM::Types::ContextEntry.new({context_key_name: "aws:SourceIp", context_key_values: [sourceip], context_key_type: "string"})
      self
    end


    def with_resource_policy(role_arn = nil, resource_arns = @resource_arns)
      @resource_arns.each do |arn|
        if arn.start_with?('arn:aws:s3:::')
          bucket = arn.scan(/arn:aws:s3:::([^\/]+)/).last.first
          sts = Aws::STS::Client.new()
          res = sts.assume_role(role_arn: role_arn, role_session_name: 'temp')
          s3 = Aws::S3::Client.new(:credentials => res)
          @policy_string = s3.get_bucket_policy(:bucket => bucket).policy.read
        end
      end
      self
    end
  end
end
