import { Meteor } from 'meteor/meteor';
import {Schemas, Transcript} from "../lib/transcript";
import { User } from "../lib/user";
import { JobCollections } from "./JobCollections";
import SimpleSchema from "simpl-schema";

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//EasySearch takes care of client and server initialization differences!
const fs = Npm.require('fs');

Meteor.publish('pendingReviewTranscripts', function (userId) {
    if (!this.userId) {
        throw new Meteor.Error(403, "Access denied");
    }
    const user = User.documents.findOne(this.userId);
    if (!(user != null ? user.isTranscriptReviewer() : undefined)) {
        throw new Meteor.Error(403, "Access denied");
    }
    this.unblock;
    return Transcript.documents.find({
        reviewCompletedOn: undefined,
        applicant: {$ne: null}
    }, {sort: {ocasRequestId: 1}});
});

Meteor.publish('transcriptSearch', function (userId, searchText) {
    if (!this.userId) {
        throw new Meteor.Error(403, "Access denied");
    }
    const user = User.documents.findOne(this.userId);
    if (!(user != null ? user.isTranscriptReviewer() : undefined)) {
        throw new Meteor.Error(403, "Access denied");
    }
    console.log(`transcriptSearch called for user ${user.displayName} with searchText ${searchText}`);
    this.unblock;
    if (searchText) {
        return Transcript.documents.find({$text: {$search: searchText}}, {score: {$meta: "textScore"}}, {
            sort: {score: {$meta: "textScore"}},
            limit: 100
        });
    } else {
        return Transcript.documents.find({}, {sort: {ocasRequestId: 1}, limit: 100});
    }
});

Meteor.publish('transcript', function (transcriptId) {
    if (!this.userId) {
        throw new Meteor.Error(403, "Access denied");
    }
    const user = User.documents.findOne(this.userId);
    if (!(user != null ? user.isTranscriptReviewer() : undefined)) {
        throw new Meteor.Error(403, "Access denied");
    }
    return Transcript.documents.find({_id: transcriptId});
});

/**
 * Work-around:
 * a["{\"msg\":\"result\",\"id\":\"4\",\"error\":{\"isClientSafe\":true,\"error\":400,\"reason\":\"Created cannot be set during an update in Transcript update\",\"details\":\"[{\\\"name\\\":\\\"created\\\",\\\"type\\\":\\\"updateNotAllowed\\\",\\\"value\\\":{\\\"$date\\\":1548163565307}}]\",\"message\":\"Created cannot be set during an update in Transcript update [400]\",\"errorType\":\"Meteor.Error\"}}"]
 * with Simple schema definition:
 * Schemas.Described = new SimpleSchema({
    title: {
        type: String
    },
    description: {
        type: String
    },
    created: {
        type: Date,
        defaultValue: new Date(),
        denyUpdate: true
    },
});

 */
const DefaultTranscript = {
    created: new Date()
}
Meteor.methods({
    createTestTranscripts() {
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptBatchJobRunner() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }

        console.log(`createTranscriptsForTesting started by ${user._id}, ${user.dn}`);
        const testTranscriptDir = "./assets/app/config/testTranscripts/";
        const files = fs.readdirSync(testTranscriptDir);
        _.each(files, file => console.log(file));
        console.log(files);
        const xmlFiles = _.filter(files, file => file.match(/\.xml$/));
        console.log(xmlFiles);
        _.each(xmlFiles, function (file) {
            const pescXml = fs.readFileSync(testTranscriptDir + file, {encoding: "UTF-8"});
            //SimpleSchema.debug = true
            const transcript = new Transcript({"title": `test ${file}`, "description": file, "created": new Date()});
            transcript.pescCollegeTranscriptXML = pescXml;
            return Transcript.documents.insert(transcript);
        });

        _(Transcript.documents.find({}).fetch()).each(transcipt => console.log(transcipt.title + ":" + transcipt._id));
        return console.log("createTranscriptsForTesting is done");
    },

    createTranscript(transcript) {
        console.log(`createTranscript called with ${JSON.stringify(transcript)}`);
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptBatchJobRunner() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }
        // Work-around Simple Schema default value issue
        Object.assign(transcript, DefaultTranscript);
        transcript = new Transcript(transcript);
        const newId = Transcript.documents.insert(transcript);
        return newId;
    },

    getTranscript(transcriptId) {
        console.log(`getTranscript called with ${JSON.stringify(transcriptId)}`);
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptBatchJobRunner() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }
        const transcript = Transcript.documents.findOne(transcriptId);
        //console.log "transcript is #{transcript}"
        return transcript;
    },


    setApplicant(transcriptId, applicant) {
        console.log(`setApplicant called with transcriptId ${transcriptId} and applicant ${JSON.stringify(applicant)}`);
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptBatchJobRunner() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }
        Transcript.documents.update({_id: transcriptId}, {$set: {applicant}});
        return true;
    },


    // Example use:
    // ddpClient.call("findRedundantJobs", [createJobConfig.root, {"data.ocasRequestId": {$in: requestIds}, status: {$ne: "failed"}}, {"data.ocasRequestId": 1}], function (err, redundantJobs) { ...}
    findRedundantJobs(jobCollectionName, redundantSelector, resultFields) {
        //console.log "findRedundantJobs called with jobCollectionName #{jobCollectionName}, redundantSelector #{JSON.stringify(redundantSelector)} and resultFields #{JSON.stringify(resultFields)}"
        let result;
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptBatchJobRunner() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }

        const jobCollection = JobCollections[jobCollectionName];
        const collection = jobCollection._collection;
        //console.log "searching Job Collection name:#{jobCollectionName}, object: #{collection}, with keys: #{_.keys(collection unless collection is undefined )}, root:#{jobCollection?.root}, JobCollections:#{JobCollections}, keys:#{_.keys(JobCollections)}"
        if (collection !== undefined) {
            result = collection.find(redundantSelector, {fields: resultFields});
        }
        return result.fetch();
    },

    // Example use:
    // ddpClient.call("findExistingTranscripts", [{ocasRequestId: {$in: newRequestIds}}, {ocasRequestId: 1}], function (error, transcriptIds) {
    findExistingTranscripts(query, fields) {
        const user = Meteor.user();
        if (!(user != null ? user.isTranscriptBatchJobRunner() : undefined)) {
            throw new Meteor.Error(403, "Access denied");
        }

        const cursor = Transcript.documents.find(query, {fields});
        return cursor.fetch();
    }
});