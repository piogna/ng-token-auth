suite 'userName registration submission', ->
  dfd = null

  suite 'successful submission', ->
    setup ->
      $httpBackend
        .expectPOST('/api/auth')
        .respond(201, {success: true})

    suite 'service module', ->
      setup ->
        dfd = $auth.submitRegistration({
          userName: validuserName
          password: 'secret123'
          password_confirmation: 'secret123'
        })

        $httpBackend.flush()

      test '$rootScope should broadcast success event', ->
        assert $rootScope.$broadcast.calledWithMatch('auth:registration-userName-success')

      test 'promise is resolved', ->
        resolved = false
        dfd.then(-> resolved = true)
        $timeout.flush()
        assert(resolved)

    suite 'directive access', ->
      args =
        userName: validuserName
        password: 'secret123'
        password_confirmation: 'secret123'

      test '$auth.submitRegistration should have been called', ->
        sinon.spy $auth, 'submitRegistration'

        $rootScope.submitRegistration(args)

        $httpBackend.flush()


  suite 'failed submission', ->
    suite 'mismatched password', ->
      errorResp =
        success: false
        errors: ['balls']
        fieldErrors: {
          password_confirmation: ['padword midmadch']
        }

      setup ->
        $httpBackend
          .expectPOST('/api/auth')
          .respond(422, errorResp)

        dfd = $auth.submitRegistration({
          userName: validuserName
          password: 'secret123'
          password_confirmation: 'bogus'
        })

        $httpBackend.flush()

      test '$rootScope should broadcast failure event', ->
        assert $rootScope.$broadcast.calledWithMatch('auth:registration-userName-error', errorResp)

      test 'promise is rejected', ->
        caught = false
        dfd.catch(-> caught = true)
        $timeout.flush()
        assert(caught)


    suite 'existing user', ->
      errorResp =
        success: false
        errors: ['balls']
        fieldErrors: {
          userName: ['user exists']
        }

      setup ->
        $httpBackend
          .expectPOST('/api/auth')
          .respond(422, errorResp)

        dfd = $auth.submitRegistration({
          userName: validuserName
          password: 'secret123'
          password_confirmation: 'bogus'
        })
        $httpBackend.flush()

      test '$rootScope should broadcast failure event', ->
        assert $rootScope.$broadcast.calledWithMatch('auth:registration-userName-error', errorResp)

      test 'promise is rejected', ->
        caught = false
        dfd.catch(-> caught = true)
        $timeout.flush()
        assert(caught)
