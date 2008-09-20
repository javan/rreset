# Adds easy defaults to writing Atom feeds with the Builder template engine (this does not work on ERb or any other
# template languages).
module ActionView
  module Helpers #:nodoc:
    module AtomFeedHelper
      # Full usage example:
      #
      #   config/routes.rb:
      #     ActionController::Routing::Routes.draw do |map|
      #       map.resources :posts
      #       map.root :controller => "posts"
      #     end
      #
      #   app/controllers/posts_controller.rb:
      #     class PostsController < ApplicationController::Base
      #       # GET /posts.html
      #       # GET /posts.atom
      #       def index
      #         @posts = Post.find(:all)
      #
      #         respond_to do |format|
      #           format.html
      #           format.atom
      #         end
      #       end
      #     end
      #
      #   app/views/posts/index.atom.builder:
      #     atom_feed do |feed|
      #       feed.title("My great blog!")
      #       feed.updated((@posts.first.created_at))
      #
      #       for post in @posts
      #         feed.entry(post) do |entry|
      #           entry.title(post.title)
      #           entry.content(post.body, :type => 'html')
      #
      #           entry.author do |author|
      #             author.name("DHH")
      #           end
      #         end
      #       end
      #     end
      #
      # The options for atom_feed are:
      #
      # * <tt>:language</tt>: Defaults to "en-US".
      # * <tt>:root_url</tt>: The HTML alternative that this feed is doubling for. Defaults to / on the current host.
      # * <tt>:url</tt>: The URL for this feed. Defaults to the current URL.
      # * <tt>:id</tt>: The id for this feed. Defaults to "tag:#{request.host},#{options[:schema_date]}:#{request.request_uri.split(".")[0]}"
      # * <tt>:schema_date</tt>: The date at which the tag scheme for the feed was first used. A good default is the year you
      #   created the feed. See http://feedvalidator.org/docs/error/InvalidTAG.html for more information. If not specified,
      #   2005 is used (as an "I don't care" value).
      #
      # Other namespaces can be added to the root element:
      #
      #   app/views/posts/index.atom.builder:
      #     atom_feed({'xmlns:app' => 'http://www.w3.org/2007/app',
      #         'xmlns:openSearch' => 'http://a9.com/-/spec/opensearch/1.1/'}) do |feed|
      #       feed.title("My great blog!")
      #       feed.updated((@posts.first.created_at))
      #       feed.tag!(openSearch:totalResults, 10)
      #
      #       for post in @posts
      #         feed.entry(post) do |entry|
      #           entry.title(post.title)
      #           entry.content(post.body, :type => 'html')
      #           entry.tag!('app:edited', Time.now)
      #
      #           entry.author do |author|
      #             author.name("DHH")
      #           end
      #         end
      #       end
      #     end
      #
      #
      # atom_feed yields an AtomFeedBuilder instance.
      def atom_feed(options = {}, &block)
        if options[:schema_date]
          options[:schema_date] = options[:schema_date].strftime("%Y-%m-%d") if options[:schema_date].respond_to?(:strftime)
        else
          options[:schema_date] = "2005" # The Atom spec copyright date
        end
 
        xml = options[:xml] || eval("xml", block.binding)
        xml.instruct!
 
        feed_opts = {"xml:lang" => options[:language] || "en-US", "xmlns" => 'http://www.w3.org/2005/Atom'}
        feed_opts.merge!(options).reject!{|k,v| !k.to_s.match(/^xml/)}
 
        xml.feed(feed_opts) do
          xml.id(options[:id] || "tag:#{request.host},#{options[:schema_date]}:#{request.request_uri.split(".")[0]}")
          xml.link(:rel => 'alternate', :type => 'text/html', :href => options[:root_url] || (request.protocol + request.host_with_port))
          xml.link(:rel => 'self', :type => 'application/atom+xml', :href => options[:url] || request.url)
 
          yield AtomFeedBuilder.new(xml, self, options)
        end
      end
 
 
      class AtomFeedBuilder
        def initialize(xml, view, feed_options = {})
          @xml, @view, @feed_options = xml, view, feed_options
        end
 
        # Accepts a Date or Time object and inserts it in the proper format. If nil is passed, current time in UTC is used.
        def updated(date_or_time = nil)
          @xml.updated((date_or_time || Time.now.utc).xmlschema)
        end
 
        # Creates an entry tag for a specific record and prefills the id using class and id.
        #
        # Options:
        #
        # * <tt>:published</tt>: Time first published. Defaults to the created_at attribute on the record if one such exists.
        # * <tt>:updated</tt>: Time of update. Defaults to the updated_at attribute on the record if one such exists.
        # * <tt>:url</tt>: The URL for this entry. Defaults to the polymorphic_url for the record.
        # * <tt>:id</tt>: The ID for this entry. Defaults to "tag:#{@view.request.host},#{@feed_options[:schema_date]}:#{record.class}/#{record.id}"
        def entry(record, options = {})
          @xml.entry do
            @xml.id(options[:id] || "tag:#{@view.request.host},#{@feed_options[:schema_date]}:#{record.class}/#{record.id}")
 
            if options[:published] || (record.respond_to?(:created_at) && record.created_at)
              @xml.published((options[:published] || record.created_at).xmlschema)
            end
 
            if options[:updated] || (record.respond_to?(:updated_at) && record.updated_at)
              @xml.updated((options[:updated] || record.updated_at).xmlschema)
            end
 
            @xml.link(:rel => 'alternate', :type => 'text/html', :href => options[:url] || @view.polymorphic_url(record))
 
            yield @xml
          end
        end
 
        private
          def method_missing(method, *arguments, &block)
            @xml.__send__(method, *arguments, &block)
          end
      end
    end
  end
end