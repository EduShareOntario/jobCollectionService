/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * DS208: Avoid top-level this
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/
import SimpleSchema from "simpl-schema";
import { User } from "./user";

const DefaultIdGenerator = {idGenerator: 'MONGO'};

const DescribedMeta = {
    abstract: true
};

export class Described extends Document {
//  title: ""
//  description: ""
//  created: undefined
    static daysAgo(days) {
        if (days == null) {
            days = 0;
        }
        const millisecondsPerDay = 24 * 60 * 60 * 1000;
        const daysAgo = new Date();
        daysAgo.setTime(daysAgo.getTime() - (days * millisecondsPerDay));
        return daysAgo;
    }
}
Described.Meta(DescribedMeta);

const TranscriptMeta = {
    name: 'Transcript',
    //wrap existing Meteor collection so we can attach schema validation

    collection: new Meteor.Collection('Transcript', DefaultIdGenerator),
    observingQuery: {
        $or: [{
            reviewCompletedOn: {$exists: false},
            outbound: {$exists: false}
        }, {outbound: {$eq: true}, created: {$gt: Described.daysAgo(300)}}]
    },
    fields: fields => {
        fields.pescCollegeTranscript = Document.GeneratedField('self', ['pescCollegeTranscriptXML'], Transcript.Meta.observingQuery, function (fields) {
            //Must return a selector that identifies the document to update and the new value
            if (!fields.pescCollegeTranscriptXML) {
                return [fields._id, undefined];
            } else {
                const object = fields.pescCollegeTranscript ? fields.pescCollegeTranscript : xml2js.parseStringSync(fields.pescCollegeTranscriptXML, {
                    attrkey: '@',
                    xmlns: false,
                    ignoreAttrs: true,
                    explicitArray: false,
                    tagNameProcessors: [xml2js.processors.stripPrefix]
                });
//          console.log "in generatedField "+fields.pescCollegeTranscriptXML + "\nobject:" + JSON.stringify(object)
                return [fields._id, object];
            }
        });

        fields.ocasRequestId = Document.GeneratedField('self', ['pescCollegeTranscript'], Transcript.Meta.observingQuery, function (fields) {
            if (!fields.pescCollegeTranscript) {
                return [fields._id, undefined];
            } else {
                const object = fields.pescCollegeTranscript.CollegeTranscript.TransmissionData.RequestTrackingID;
                return [fields._id, object];
            }
        });

        fields.reviewer = Document.ReferenceField(User, ['mail', 'displayName'], {});

        return fields;
    }
};

export class Transcript extends Described {
//  pescCollegeTranscriptXML: undefined
//  pescCollegeTranscript: undefined
//  reviewStartedOn: undefined
//  reviewCompletedOn: undefined
//  reviewer: undefined
    fullName() {
        const name = this.pescCollegeTranscript.CollegeTranscript.Student.Person.Name;
        return name.FirstName + ' ' + name.LastName;
    }

    transcriptXmlDump() {
        return this.pescCollegeTranscriptXML;
    }

    transcriptJsonDump() {
        return JSON.stringify(this.pescCollegeTranscript, null, '\t');
    }

    awaitingReview() {
        return (this.reviewCompletedOn === undefined) && (this.reviewer === undefined) && !this.outbound;
    }

    reviewable() {
        return !this.outbound && !this.reviewCompletedOn && (!this.reviewer || this.reviewerIsMe());
    }

    reviewerNotMe() {
        return this.reviewer && !this.reviewerIsMe();
    }

    reviewerIsMe() {
        return (this.reviewer != null ? this.reviewer._id : undefined) === Meteor.userId();
    }

    myId() {
        return this.__originalId || this._id;
    }
}
Transcript.Meta(TranscriptMeta);

export const Schemas = {};

Schemas.Described = new SimpleSchema({
    title: {
        type: String
    },
    description: {
        type: String
    },
    created: {
        type: Date,
        defaultValue: new Date(),
        denyUpdate: true,
        optional: true
    },
});

Schemas.Transcript = new SimpleSchema({
    pescCollegeTranscriptXML: {
        type: String,
        optional: true
    },
    pescCollegeTranscript: {
        type: Object,
        optional: true,
        blackbox: true
    },
    ocasRequestId: {
        type: String,
        optional: true
    },
    reviewStartedOn: {
        type: Date,
        optional: true
    },
    reviewCompletedOn: {
        type: Date,
        optional: true
    },
    reviewer: {
        type: User,
        optional: true,
        blackbox: true
    },
    applicant: {
        type: Object,
        optional: true,
        blackbox: true
    },
    outbound: {
        type: Boolean,
        optional: true
    }
});
Schemas.Transcript.extend(Schemas.Described);

Schemas.EasySearchTranscript = new SimpleSchema({
    __originalId: {
        type: String,
        optional: true
    }
});
Schemas.EasySearchTranscript.extend(Schemas.Transcript);

Schemas.Applicant = new SimpleSchema({});

// The Collection2 package will take care of validating a document on save when a 'schema' is associated with the collection.
Transcript.Meta.collection.attachSchema(Schemas.EasySearchTranscript);

Meteor.methods({
    completeReview(transcriptId) {
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptReviewer() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }
        const exists = Transcript.documents.exists({_id: transcriptId});
        if (exists) {
            console.log(`${user._id}, ${user.dn} : completeReview for transcript:` + transcriptId);
            return Transcript.documents.update({
                _id: transcriptId,
                reviewCompletedOn: null,
                'reviewer._id': user._id
            }, {$set: {reviewCompletedOn: new Date()}});
        } else {
            return console.log(`${user._id}, ${user.dn} : completeReview failed for transcript:` + transcriptId + " ; a document with this id does not exist!");
        }
    },

    startReview(transcriptId) {
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptReviewer() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }
        console.log(`${user._id}, ${user.dn} : startReview for transcript:` + transcriptId);
        return Transcript.documents.update({
            _id: transcriptId,
            reviewCompletedOn: null,
            outbound: null
        }, {$set: {reviewStartedOn: new Date(), 'reviewer._id': user._id}});
    },

    cancelReview(transcriptId) {
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptReviewer() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }
        console.log(`${user._id}, ${user.dn} : cancelReview for transcript:` + transcriptId);
        return Transcript.documents.update({
            _id: transcriptId,
            reviewCompletedOn: null,
            'reviewer._id': user._id
        }, {$unset: {reviewStartedOn: "", reviewer: ""}, $set: {reviewCancelledOn: new Date()}});
    }
});
