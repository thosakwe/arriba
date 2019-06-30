import React from 'react';
import CloudDownloadIcon from '@material-ui/icons/CloudDownload'
import List from '@material-ui/core/List'
import ListItem from '@material-ui/core/ListItem'
import ListItemIcon from '@material-ui/core/ListItemIcon'
import ListItemText from '@material-ui/core/ListItemText'

export default ({items}) => {
  return (
    <List>
      {items.map(item => {
        const onClick = () => {
          window.open(item.url);
        };
        return (
          <ListItem key={item.url} button onClick={onClick}>
            <ListItemIcon>
              <CloudDownloadIcon/>
            </ListItemIcon>
            <ListItemText primary={item.filename}/>
            <ListItemText secondary={`Uploaded by ${item.user.name} - ${item.size} (${item.mime_type})`}/>
          </ListItem>);
      })}
    </List>);
};