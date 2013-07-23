module Twitter
  class User
    attr_accessor :ac_account

    def initialize(ac_account)
      self.ac_account = ac_account
    end

    def username
      self.ac_account.username
    end

    # user.compose(tweet: 'initial tweet', images: [ui_image, ui_image],
    #   urls: ["http://", ns_url, ...]) do |composer|
    #
    # end
    def compose(options = {}, &block)
      @composer = Twitter::Composer.new
      @composer.compose(options) do |composer|
        block.call(composer)
      end
    end

    # user.get_timeline(include_entities: 1) do |hash, ns_error|
    # end
    def get_timeline(options = {}, &block)
      url = NSURL.URLWithString("http://api.twitter.com/1.1/statuses/home_timeline.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      request.performRequestWithHandler(lambda {|response_data, url_response, error|
        if !response_data
          block.call(nil, error)
        else
          block.call(BubbleWrap::JSON.parse(response_data), nil)
        end
      })
    end

    # Returns up to 5,000 friend ids, have to implement Cursors to access multiple pages of results
    # def friend_ids(options = {}, &block)
    #   url = NSURL.URLWithString("http://api.twitter.com/1.1/friends/ids.json")
    #   request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
    #   request.account = self.ac_account
    #   request.performRequestWithHandler(lambda {|response_data, url_response, error|
    #     if !response_data
    #       block.call(nil, error)
    #     else
    #       block.call(BubbleWrap::JSON.parse(response_data), nil)
    #     end
    #   })
    # end

        # Returns up to 5,000 follower ids, have to implement Cursors to access multiple pages of results
    # def follower_ids(options = {}, &block)
    #   url = NSURL.URLWithString("http://api.twitter.com/1.1/followers/ids.json")
    #   request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
    #   request.account = self.ac_account
    #   request.performRequestWithHandler(lambda {|response_data, url_response, error|
    #     if !response_data
    #       block.call(nil, error)
    #     else
    #       block.call(BubbleWrap::JSON.parse(response_data), nil)
    #     end
    #   })
    # end

    # def users(options = {}, &block)
    #   url = NSURL.URLWithString("http://api.twitter.com/1.1/users/lookup.json")
    #   request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
    #   request.account = self.ac_account
    #   request.performRequestWithHandler(lambda {|response_data, url_response, error|
    #     if !response_data
    #       block.call(nil, error)
    #     else
    #       block.call(BubbleWrap::JSON.parse(response_data), nil)
    #     end
    #   })
    # end


    # This method will lock the thread it is called in because it is Synchronous
    # Returns up to 5,000 friend ids, have to implement Cursors to access multiple pages of results
    def friend_ids(options = {})
      url = NSURL.URLWithString("http://api.twitter.com/1.1/friends/ids.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      ns_url_request = request.signedURLRequest
      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)
      ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)
      return BubbleWrap::JSON.parse(ns_data)
    end

    # This method will lock the thread it is called in because it is Synchronous
    # Returns up to 5,000 follower ids, have to implement Cursors to access multiple pages of results
    def follower_ids(options = {})
      url = NSURL.URLWithString("http://api.twitter.com/1.1/followers/ids.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      ns_url_request = request.signedURLRequest
      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)
      ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)
      return BubbleWrap::JSON.parse(ns_data)
    end

    # This method will lock the thread it is called in because it is Synchronous
    # Returns up to 100 hydrated users can call it 180 times in a 15 minute span
    def users(*args)
      options = { user_id: args.join(",") }
      url = NSURL.URLWithString("http://api.twitter.com/1.1/users/lookup.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      ns_url_request = request.signedURLRequest
      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)
      ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)
      return BubbleWrap::JSON.parse(ns_data)
    end


    # Allows the authenticating user to unfollow the specified users
    #
    # @see https://dev.twitter.com/docs/api/1.1/post/friendships/destroy
    # @rate_limited No
    # @authentication Requires user context
    # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
    # @return [Array<Twitter::User>] The unfollowed users.
    # @overload unfollow(*users)
    #   @param users [Enumerable<Integer, String, Twitter::User>] A collection of Twitter user IDs, screen names, or objects.
    #   @example Unfollow @sferik
    #     Twitter.unfollow('sferik')
    # @overload unfollow(*users, options)
    #   @param users [Enumerable<Integer, String, Twitter::User>] A collection of Twitter user IDs, screen names, or objects.
    #   @param options [Hash] A customizable set of options.

    def unfollow(options = {}, &block)
      url = NSURL.URLWithString("http://api.twitter.com/1.1/friendships/destroy.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodPOST)
      request.account = self.ac_account
      # request.signedURLRequest

      request.performRequestWithHandler(lambda {|response_data, url_response, error|

        if !response_data
          block.call(nil, error)
        else
          block.call(BubbleWrap::JSON.parse(response_data), nil)
        end
      })
    end

    def follow(options = {}, &block)
      url = NSURL.URLWithString("http://api.twitter.com/1.1/friendships/create.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodPOST)
      request.account = self.ac_account
      # request.signedURLRequest

      request.performRequestWithHandler(lambda {|response_data, url_response, error|

        if !response_data
          block.call(nil, error)
        else
          block.call(BubbleWrap::JSON.parse(response_data), nil)
        end
      })
    end

  end
end