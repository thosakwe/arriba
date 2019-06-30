import React from 'react';
import Avatar from '@material-ui/core/Avatar'
import List from '@material-ui/core/List'
import ListItem from '@material-ui/core/ListItem'
import ListItemAvatar from '@material-ui/core/ListItemAvatar'
import ListItemText from '@material-ui/core/ListItemText'

export default ({users}) => {
  return (
    <List>
      {users.map(user => {
        return (
          <ListItem key={user.id} button>
            <ListItemAvatar>
              <Avatar alt={user.name} src={user.avatar_url} />
            </ListItemAvatar>
            <ListItemText primary={user.name}/>
          </ListItem>);
      })}
    </List>);
};