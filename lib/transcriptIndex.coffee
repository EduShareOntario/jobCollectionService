#EasySearch takes care of client and server initialization differences!
@TranscriptIndex = new EasySearch.Index
  name: 'transcript'
#  fields: ['title', 'description', 'reviewer', 'ocasRequestId']
  fields: ['title'] # need at least one!
  defaultSearchOptions: { limit: 20 }
  engine: new EasySearch.ElasticSearch
    fieldsToIndex: (indexConfig) ->
      ['title', 'description','pescCollegeTranscriptXML', 'reviewer', 'ocasRequestId', 'outbound', 'applicant', 'reviewCompletedOn']
    transform: (doc) ->
      try
        doc = new Transcript doc
      catch error
        # Caution: throwing an error will result in an endless loop of sub/unsub by the client!
        console.log error
        console.log doc
      return doc

    query: (searchObject, options) ->
      fieldNames = Object.keys(searchObject)
      searchText = searchObject[fieldNames[0]] # use the first property because they are all the same!
      filterType = options.search.props.filter
      match = undefined
      if searchText?.length > 0
        match =
          "multi_match":
            query: searchText
            type: "best_fields"
            tie_breaker: 0.2
            fields: [
              'title'
            , 'description'
            , 'reviewer.displayName'
            , 'ocasRequestId.exact^3'
            , 'ocasRequestId.ngram'
            , 'applicant.firstName.exact^3'
            , 'applicant.firstName.ngram'
            , 'applicant.lastName.exact^3'
            , 'applicant.lastName.ngram'
            , 'applicant.studentId.exact^3'
            , 'applicant.studentId.ngram'
            , 'applicant.applicantId.exact^2'
            , 'applicant.applicantId.ngram'
            , 'pescCollegeTranscriptXML'
            ]

      switch filterType
        when "pendingReview"
          reviewerExists =
            exists:
              field: "reviewer"
          outboundExists =
            exists:
              field: "outbound"
          filter =
            bool:
              must:
                exists:
                  field: "applicant"
              must_not : [reviewerExists, outboundExists]
        when "reviewerIsMe"
          filter =
            match:
              "reviewer._id" : options.search.userId
        when "reviewed"
          filter =
            exists:
              field: "reviewCompletedOn"
        when "outbound"
          filter =
            match:
              outbound: 1

      if not filter? and not match?
        query =
          match_all: {}
      else
        query = bool: {}
        query.bool = {filter:filter} if filter and match
        query.bool = {must:filter} if filter and not match
        query.bool.should = match if match

      return query

    sort: (searchObject, options) ->
      if searchObject.title is ''
        s = [{"ocasRequestId": {"order": "asc"}}]
      else
        s = [{"_score": {"order": "desc"}}]
      return s

    body: (body) ->
      body.fields = ["_id"]
      body.min_score = 0.0005
      console.log JSON.stringify body
      return body

  collection: Transcript.Meta.collection
  permission: (options) ->
    user = User.documents.findOne options.userId
    return user?.isTranscriptReviewer()

if (Meteor.isServer)
  Transcript.Meta.collection._ensureIndex ocasRequestId: 1, created: 1
  Transcript.Meta.collection._ensureIndex reviewCompletedOn: 1


