import {Meteor} from 'meteor/meteor';
import {Transcript} from "./transcript";
import {User} from "./user";
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * DS208: Avoid top-level this
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

//EasySearch takes care of client and server initialization differences!
export const TranscriptIndex = new EasySearch.Index({
    name: 'transcript',
//  fields: ['title', 'description', 'reviewer', 'ocasRequestId']
    fields: ['title'], // need at least one!
    defaultSearchOptions: {limit: 20, sort: {ocasRequestId: 1}},
    engine: new EasySearch.ElasticSearch({
        fieldsToIndex(indexConfig) {
            return ['title', 'description', 'pescCollegeTranscriptXML', 'reviewer', 'ocasRequestId', 'outbound', 'applicant', 'reviewCompletedOn'];
        },
        transform(doc) {
            try {
                doc = new Transcript(doc);
            } catch (error) {
// Caution: throwing an error will result in an endless loop of sub/unsub by the client!
                console.log(error);
                console.log(doc);
            }
            return doc;
        },

        query(searchObject, options) {
            let filter, query;
            const fieldNames = Object.keys(searchObject);
            const searchText = searchObject[fieldNames[0]]; // use the first property because they are all the same!
            const filterType = options.search.props.filter;
            let match = undefined;
            if ((searchText != null ? searchText.length : undefined) > 0) {
                match = {
                    "multi_match": {
                        query: searchText,
                        type: "best_fields",
                        tie_breaker: 0.2,
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
                    }
                };
            }

            switch (filterType) {
                case "pendingReview":
                    var reviewCompletedOnExists = {
                        exists: {
                            field: "reviewCompletedOn"
                        }
                    };
                    var outboundExists = {
                        exists: {
                            field: "outbound"
                        }
                    };
                    filter = {
                        bool: {
                            must: {
                                exists: {
                                    field: "applicant"
                                }
                            },
                            must_not: [reviewCompletedOnExists, outboundExists]
                        }
                    };
                    break;
                case "reviewerIsMe":
                    filter = {
                        match: {
                            "reviewer._id": options.search.userId
                        }
                    };
                    break;
                case "reviewed":
                    filter = {
                        exists: {
                            field: "reviewCompletedOn"
                        }
                    };
                    break;
                case "outbound":
                    filter = {
                        match: {
                            outbound: 1
                        }
                    };
                    break;
            }

            if ((filter == null) && (match == null)) {
                query =
                    {match_all: {}};
            } else {
                query = {bool: {}};
                if (filter && match) {
                    query.bool = {filter};
                }
                if (filter && !match) {
                    query.bool = {must: filter};
                }
                if (match) {
                    query.bool.should = match;
                }
            }

            return query;
        },

        sort(searchObject, options) {
            let s;
            if (searchObject.title === '') {
                s = [{"ocasRequestId.exact": {"order": "asc", "missing": "_last"}}];
            } else {
                s = ["_score"];
            }
            return s;
        },

        body(body, options) {
            body.fields = [];
            body.min_score = 0.0005;
            console.log(JSON.stringify(body));
            return body;
        }
    }),

    collection: Transcript.Meta.collection,
    observingQuery: Transcript.Meta.observingQuery,
    permission(options) {
        const user = User.documents.findOne(options.userId);
        return (user != null ? user.isTranscriptReviewer() : undefined);
    }
});

if (Meteor.isServer) {
    Transcript.Meta.collection._ensureIndex({ocasRequestId: 1, created: 1});
    Transcript.Meta.collection._ensureIndex({reviewCompletedOn: 1});
}
