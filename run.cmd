set METEOR_SETTINGS={  "jobCollections": [    {      "name": "student-transcript",      "adminUserIds": [        ],      "adminGroups": [        "GG-ADMIN-Information Technology-Enterprise Systems-Production"      ],      "scheduledJobs": [        "getInboundTranscriptRequestIdsFromOCAS"        ,"getOutboundTranscriptRequestIdsFromOCAS"      ]    }  ],  "public": {    "jobCollections": [      {        "name": "student-transcript"      }    ],    "transcriptToHtmlURL": "http://apps.georgiantest.com/transformdoc"  },  "ldap": {    "debug": true,    "domain": "georgiancollege.ca",    "baseDn": "ou=Georgian,dc=admin,dc=georgianc,dc=on,dc=ca",    "url": "ldap://badcadm03.admin.georgianc.on.ca/",    "bindCn": "cn=0-LDAPGrails,ou=Service Accounts,ou=Georgian,dc=admin,dc=georgianc,dc=on,dc=ca",    "bindPassword": "Gr00vy:Tra1n",    "autopublishFields": [      "displayName",      "givenName",      "department",      "employeeNumber",      "mail",      "title",      "address",      "phone"    ],    "groupMembership": [      "APP-XML-TransQueue"    ]  }}
set ROOT_URL=http://localhost:3000
set PORT=3000
set MONGO_URL=mongodb://transcriptTest:%npm_config_mongopass%@bamongodb01:27017,bamongodb02:27017,bamongodb03:27017/transcriptTest?replicaSet=rs1^&authSource=admin
set NODE_OPTIONS=--max_old_space_size=2500
set
cd .target/bundle
meteor node main.js