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
      url = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/home_timeline.json")
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
    #   url = NSURL.URLWithString("https://api.twitter.com/1.1/friends/ids.json")
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


    def verify_credentials(options = {})
      default_options = {
        skip_status: true,
        include_entities: false
      }
      options.merge(default_options)

      url = NSURL.URLWithString("https://api.twitter.com/1.1/account/verify_credentials.json")

      get(url, options)
    end

    def get(url, options={})
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      ns_url_request = request.signedURLRequest
      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)
      ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)
      return BubbleWrap::JSON.parse(ns_data)
    end


    # This method will lock the thread it is called in because it is Synchronous
    # Returns up to 5,000 friend ids, have to implement Cursors to access multiple pages of results
    def friend_ids(options = {})
      url = NSURL.URLWithString("https://api.twitter.com/1.1/friends/ids.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      ns_url_request = request.signedURLRequest
      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)
      ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)
      return BubbleWrap::JSON.parse(ns_data)
    end


    # friendships/show
    # https://api.twitter.com/1.1/friendships/show.json?source_screen_name=bert&target_screen_name=ernie
    def friendships_show(source_screen_name, target_screen_name)
      url = NSURL.URLWithString("https://api.twitter.com/1.1/friendships/show.json?")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      ns_url_request = request.signedURLRequest
      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)
      ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)
      return BubbleWrap::JSON.parse(ns_data)
    end


    # def all_friend_ids(options = {cursor: "-1"})
    #   url = NSURL.URLWithString("https://api.twitter.com/1.1/friends/ids.json")
    #   request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
    #   request.account = self.ac_account
    #   ns_url_request = request.signedURLRequest
    #   ns_url_response_ptr = Pointer.new(:object)
    #   error_ptr = Pointer.new(:object)
    #   ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)
    #   return BubbleWrap::JSON.parse(ns_data)
    # end

    def all_friend_ids(options = {})
      cursor = "-1"
      all_ids = []
      account = self.ac_account
      url = NSURL.URLWithString("https://api.twitter.com/1.1/friends/ids.json")

      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)

      options = { cursor: cursor }

      while (options[:cursor].to_i != 0)
        request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
        request.account = account
        ns_url_request = request.signedURLRequest

        ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error: error_ptr)

        json_data = BubbleWrap::JSON.parse(ns_data)

        options[:cursor] = json_data[:next_cursor_str]
        all_ids = all_ids + json_data[:ids]
      end

      resp = { ids: all_ids }

      return resp
    end

    def all_follower_ids(options = {})
      default_options = { cursor: "-1" }
      options = default_options.merge(options)
      ids_obj = { ids: [] }
      url = NSURL.URLWithString("https://api.twitter.com/1.1/followers/ids.json")

      # while options[:cursor].to_i != 0
      15.times do
        json_data = get(url, options)
        options[:cursor] = json_data[:next_cursor_str]
        ids_obj[:ids] = ids_obj[:ids] + json_data[:ids]
        # puts "Cursor: #{options[:cursor]}"
        break if options[:cursor].to_i == 0
      end

      return ids_obj
    end

    # This method will lock the thread it is called in because it is Synchronous
    # Returns up to 5,000 follower ids, have to implement Cursors to access multiple pages of results
    def follower_ids(options = {})
      url = NSURL.URLWithString("https://api.twitter.com/1.1/followers/ids.json")
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
      url = NSURL.URLWithString("https://api.twitter.com/1.1/users/lookup.json")
      request = TWRequest.alloc.initWithURL(url, parameters:options, requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      ns_url_request = request.signedURLRequest
      ns_url_response_ptr = Pointer.new(:object)
      error_ptr = Pointer.new(:object)
      ns_data = NSURLConnection.sendSynchronousRequest(ns_url_request, returningResponse:ns_url_response_ptr, error:error_ptr)
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
      url = NSURL.URLWithString("https://api.twitter.com/1.1/friendships/destroy.json")
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
      url = NSURL.URLWithString("https://api.twitter.com/1.1/friendships/create.json")
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