# device-status-roaming-subscriptions-retrieveDeviceRoamingStatusSubscriptionList
Feature: Device Roaming Status Subscriptions API, vwip - Operation retrieveDeviceRoamingStatusSubscriptionList

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * List of device identifier types which are not supported, among: phoneNumber, networkAccessIdentifier, ipv4Address, ipv6Address
  #
  # Testing assets:
  # * A device object whose roaming status is known by the network when connected.
  # * The known roaming status of the testing device
  # * A sink-url identified as "callbackUrl", which receives notifications
  #
  # References to OAS spec schemas refer to schemas specified in device-roaming-status-subscriptions.yaml

  Background: Common Device Roaming Status Subscriptions setup
    Given the resource "{apiroot}/device-roaming-status-subscriptions/vwip/subscriptions" as base-url
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

##########################
# Happy path scenarios
##########################

  @roaming_status_subscriptions_01_retrieve_list_2legs
  Scenario: Check existing subscription(s) is/are retrieved in list with a 2-legged access token
    Given at least one subscription is existing for the API consumer making this request
    And the header "Authorization" is set to a valid access token which does not identify any device
    When the request "retrieveDeviceRoamingStatusSubscriptionList" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with an array of OAS schema defined at "#/components/schemas/Subscription"
    And the response body lists all subscriptions belonging to the API consumer

  @roaming_status_subscriptions_02_retrieve_list_3legs
  Scenario: Check existing subscription(s) is/are retrieved in list with a 3-legged access token
    Given the API consumer has at least one active subscription for the device
    And the header "Authorization" is set to a valid access token which identifies a valid device associated with one or more subscriptions
    When the request "retrieveDeviceRoamingStatusSubscriptionList" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with an array of OAS schema defined at "#/components/schemas/Subscription"
    And the response body lists all subscriptions belonging to the API consumer for the identified device
    And the response property "$.config.subscriptionDetail.device" is not present in any of the subscription records

  @roaming_status_subscriptions_03_retrieve_empty_list_3legs
  Scenario: Check no existing subscription is retrieved in list
    Given the API consumer has no active subscriptions for the device
    And the header "Authorization" is set to a valid access token which identifies a valid device
    When the request "retrieveDeviceRoamingStatusSubscriptionList" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body is an empty array

################
# Error scenarios for management of input parameter device
##################

##################
# Error code 400
##################

##################
# Error code 401
##################

  @roaming_status_subscriptions_retrieve_list_401.01_no_authorization_header
  Scenario: No Authorization header
    Given the request header "Authorization" is removed
    When the request "retrieveDeviceRoamingStatusSubscriptionList" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @roaming_status_subscriptions_retrieve_list_401.02_expired_access_token
  Scenario: Expired access token
    Given the header "Authorization" is set to a previously valid but now expired access token
    When the request "retrieveDeviceRoamingStatusSubscriptionList" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @roaming_status_subscriptions_retrieve_list_401.03_malformed_access_token
  Scenario: Malformed access token
    Given the header "Authorization" is set to a malformed token
    When the request "retrieveDeviceRoamingStatusSubscriptionList" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

##################
# Error code 403
##################

##################
# Error code 404
##################

##################
# Error code 422
##################
