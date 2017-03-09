# Artichoke

Artichoke is a library for gmail integration within testing suites. Artichoke is best used in conjuction with integration test tools such as RSpec, Capybara, and/or Cucumber. Artichoke uses Mail objects for storing the emails. The emails will not be marked as read on Gmail.

## Installation

Add this line to your application's Gemfile:

    gem 'artichoke'

Or install it yourself as:

    $ gem install artichoke


## Configuration

Add this to an initializer:

    Artichoke::Connection.configure do |config|
      config.username = 'ninja@gmail.com'
      config.password = 'topsecret'
    end

## Setting Poller Start Time

Artichoke uses a email polling system to find and evaluate email(s) information that can be later used for assertions or follow up actions. In order to set the start time for the polling system, you must create an instance of the poller for later use:

    @poller = Artichoke::Poller.new

This is best used prior to an action that should trigger the email you want to evaluate.


### Find email by subject

    #    You can pass in a defined timeout period for the poller to execute
    #    and if not defined, it will default to 75 seconds.
    email = @poller.find({message_subject: "Ninjas are coming!!", timeout: 30})


### Partial subject match
    
    # By default, artichoke will only find emails with exact match of the email's subject. 
    # You can pass in a flag for allowing emails with partial subject matches
    email = @poller.find({message_subject: "Ninjas are", timeout: 30, partial_subject_match: true})

### Find email by subject and content(s)
    
    # Find email by subject and single content criteria
    email = @poller.find({message_subject: "Shinobi Poetry", timeout: 30, content: ["Blackest day"]})

    # Find email by subject and multiple content criteria
    email = @poller.find({message_subject: "Shinobi Poetry", timeout: 30, content: ["Blackest day", "Katana night"]})

### Find email by subject and/or content(s) and/or attachment filenames
    
    email = @poller.find({message_subject: "Shinobi Poetry", timeout: 30, content: ["Blackest day"], attachments: ["yohashi.pdf", "shuriken.png"]})

    
### Assert that no email was sent with given criteria

    #    By default, the poller raises an error if no email was found
    #    within the determined timeout. However, you can pass the skip_error parameter
    #    in order to silence the error, so that you can assert no email was sent.
    email = @poller.find({message_subject: "I wear Kimonos on weekends", timeout: 30, skip_error: true})
    email.should be_nil

### Count number of emails that fit given criteria

    email = @poller.count({message_subject: "With every death, comes honor. With honor, redemption.", content: ["See through the dragon's eyes."]})
    email.should eq(2)

### Evaluating and Manipulating the returned Message object

    # You can now do evaluations on the email, such as reading the body
    email.message_content.should have_content "I am forever in your debt master..."

    #   You can also evaluate attachments by calling email.attachments
    #   or return the first attachment's filename by using
    email.attachment_name

For more operations that can be performed on the Message object, please visit [Mail](http://rubygems.org/gems/mail) rubygem. See its [documentation here](http://github.com/mikel/mail).