import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:singhealth_app/custom_icons_icons.dart';
import 'package:singhealth_app/setup/welcome.dart';


class StaffHome extends StatefulWidget {
  @override


  StaffHome({
    Key key,
    this.user}) : super(key: key);

  final User user;
  final firestoreInstance = FirebaseFirestore.instance;


  _StaffHomeState createState() => _StaffHomeState(user,firestoreInstance);
}

class _StaffHomeState extends State<StaffHome> {

  User user;
  FirebaseFirestore firestoreInstance;

  dynamic data;

  _StaffHomeState(user,firestoreInstance){
    this.user = user;
    this.firestoreInstance = firestoreInstance;
  }


  Future<dynamic> staffInformation() async {

    final DocumentReference document =   firestoreInstance.collection("staff").doc(user.uid);
    print(user.uid);
    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        data =snapshot.data();
      });
    });
  }

  @override
  void initState(){
    super.initState();
    staffInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Welcome ${data["name"]}, you are logged in as staff'),
      ),
      body: Center(
        child: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(vertical: 50, horizontal: 500),
                  padding: EdgeInsets.all(25),
                  color: Colors.green[100],
                  child: Row(
                    children: <Widget> [
                      Column(
                        children: <Widget> [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            child: Text("Name: ${data["name"]}"),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            child: Text("Branch Location: ${data["institution"]}"),
                          ),
                        ],
                      ),

                      Column(
                        children: <Widget> [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            child: Text("Tenancy Number: ${data["id"]}"),
                          ),
                        ],
                      ),

                      Container(
                        margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: AssetImage('images/PolarLogo.jpg'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  )
              ),

              Container(
                  margin: EdgeInsets.symmetric(vertical: 25, horizontal: 500),
                  padding: EdgeInsets.all(25),
                  color: Colors.orange[100],
                  child: Row(
                    children: <Widget> [
                      Container(
                        padding: EdgeInsets.fromLTRB(25, 10, 135, 10),
                        child: Text("Account & Institution"),
                      ),

                      Column(
                        children: <Widget> [
                          IconButton(icon: Icon(CustomIcons.clipboard_user), onPressed: null),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            child: Text("Account"),
                          ),
                        ],
                      ),

                      Column(
                        children: <Widget> [
                          IconButton(icon: Icon(CustomIcons.clipboard_checklist), onPressed: null),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 60),
                            child: Text("Tenant Details"),
                          ),
                        ],
                      ),

                      Column(
                        children: <Widget> [
                          IconButton(icon: Icon(CustomIcons.document), onPressed: null),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: Text("Institution Details"),
                          ),
                        ],
                      ),
                    ],
                  )
              ),

              Container(
                  margin: EdgeInsets.symmetric(vertical: 25, horizontal: 500),
                  padding: EdgeInsets.all(25),
                  color: Colors.red[100],
                  child: Row(
                    children: <Widget> [
                      Container(
                        padding: EdgeInsets.fromLTRB(25, 10, 50, 10),
                        child: Text("Non-compliance Incidents"),
                      ),

                      Column(
                        children: <Widget> [
                          IconButton(icon: Icon(CustomIcons.calendar_exclamation), onPressed: null),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            child: Text("Upload Incident"),
                          ),
                        ],
                      ),

                      Column(
                        children: <Widget> [
                          IconButton(icon: Icon(CustomIcons.history), onPressed: null),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            child: Text("Review Incident Status"),
                          ),
                        ],
                      ),
                    ],
                  )
              ),

              RaisedButton.icon(
                icon: Icon(CustomIcons.sign_out),
                label: Text("Sign Out"),
                textColor: Colors.white,
                color: Colors.blue[300],
                onPressed: signOut,
              ),
            ]
        ),
      ),
    );
  }

  Future<void> signOut() async{
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> WelcomePage()));
  }


}

