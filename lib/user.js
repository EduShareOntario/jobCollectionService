const UserMeta = {
    name: 'User',
    collection: Meteor.users
};
export class User extends Document {
  isTranscriptReviewer() {
    return (this.memberOf != null ? this.memberOf.length : undefined) > 0;
  }

  isTranscriptBatchJobRunner() {
    return this.isMemberOf('batch job') || this.batchJobRunner;
  }

  isMemberOf(group) {
    return this.memberOf && Array.from(this.memberOf).includes(group);
  }
}

User.Meta(UserMeta);
