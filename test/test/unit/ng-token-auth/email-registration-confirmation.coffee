suite 'userName registration confirmation', ->
  dfd = null
  suite 'successful registration', ->
    setup ->
      $httpBackend
        .expectGET('/api/auth/validate_token')
        .respond(201, {
          sucess: true
          data: validUser
        })

      # mock the querystring for the userName confirmation link
      setValiduserNameConfirmQS()

      dfd = $auth.validateUser()
      $httpBackend.flush()

    test 'new user is defined in the root scope', ->
      assert.equal(validUser.uid, $rootScope.user.uid)

    test '$rootScope broadcast validation success event', ->
      assert $rootScope.$broadcast.calledWith('auth:validation-success')    

    test '$rootScope broadcast userName confirmation success event', ->
      assert $rootScope.$broadcast.calledWith('auth:userName-confirmation-success')

    test 'token expiry is set', ->
      assert.equal(validExpiry * 1000, $auth.getConfig().parseExpiry($auth.retrieveData('auth_headers')))

    test 'promise is resolved', ->
      resolved = false
      dfd.then(-> resolved = true)
      $timeout.flush()
      assert(resolved)

  suite 'successful oauth registration', ->
    setup ->
      $httpBackend
        .expectGET('/api/auth/validate_token')
        .respond(201, {
          sucess: true
          data: validUser
        })

      # mock the querystring coming back from an oauth registration
      setValidOauthRegistrationQS();

      dfd = $auth.validateUser()
      $httpBackend.flush()

    test '$rootScope broadcast oauth registration event', ->
      assert $rootScope.$broadcast.calledWith('auth:oauth-registration')


  suite 'failed registration', ->
    setup ->
      $httpBackend
        .expectGET('/api/auth/validate_token')
        .respond(401, {
          sucess: false
          errors: 'balls'
        })

      # mock the querystring for the userName confirmation link
      setValiduserNameConfirmQS()

      dfd = $auth.validateUser()
      $httpBackend.flush()

    test 'new user is not defined in the root scope', ->
      assert.equal(undefined, $rootScope.user.uid)

    test '$rootScope broadcast validation error event', ->
      assert $rootScope.$broadcast.calledWith('auth:validation-error')

    test '$rootScope broadcast userName confirmation error event', ->
      assert $rootScope.$broadcast.calledWith('auth:userName-confirmation-error')

    test 'promise is rejected', ->
      caught = false
      dfd.catch(-> caught = true)
      $timeout.flush()
      assert(caught)
