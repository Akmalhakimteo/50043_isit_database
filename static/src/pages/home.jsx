import React, { Component } from 'react';
import { Switch, Route } from 'react-router-dom';
import _ from 'lodash';
import NavBar from '../components/NavBar';
import AllBooks from '../components/AllBooks';
import BookDetails from './BookDetails';
import UserAction from '../pages/UserAction';

import {
    Container,

    Message,
    Segment,
    Grid,
    Header
} from 'semantic-ui-react';

class Home extends Component {
    render() {
        return (
            <div>
                <NavBar/>
                <Container style={{marginTop: '2em', marginBottom: '4em'}}>
                    <Switch>
                        <Route exact path='/'>
                            <Grid>
                                <Grid.Row>
                                    <Grid.Column width={4}>
                                        <Segment>
                                            <Header as='h3' dividing>
                                                Hello
                                            </Header>
                                        </Segment>
                                    </Grid.Column>
                                    <AllBooks/>
                                </Grid.Row>
                            </Grid>
                        </Route>
                        <Route path="/user_action" component={UserAction}/>
                        <Route exact path='/review/:asin' component={BookDetails}/>
                    </Switch>
                </Container>
            </div>
        )
    }
}

export default Home;