DOCUMENTATION = '''
---
module: win-ad-users
version_added: "0.1"
short_description: Add AD Groups to members
description:
     - Adds AD Group.
options:
state:
    description: Adds a new AD Group to member if state is Absent Deletes the Group from Member is state is Present
    choices: ['absent', 'present']
    default: 'absent'
  member:
    description: Member name
    required: yes
  group:
    description: Group name
    required: yes
  Author: Marc Hoogendoorn
'''

EXAMPLES = '''
Win-ad-groups:
  state: present
  member: Marc
  group: Administrator

'''