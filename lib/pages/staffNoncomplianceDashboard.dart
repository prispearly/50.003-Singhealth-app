

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'staffDashboardIncidentDetails.dart';


class StaffNonComplianceDashboard extends StatefulWidget {
  @override
  StaffNonComplianceDashboard({
    Key key,
    this.user}) : super(key: key);

  final User user;
  final firestoreInstance = FirebaseFirestore.instance;


  _StaffNonComplianceDashboardState createState() => _StaffNonComplianceDashboardState(user,firestoreInstance);
}

class _StaffNonComplianceDashboardState extends State<StaffNonComplianceDashboard> {

  User user;
  FirebaseFirestore firestoreInstance;
  List<String> tenantList,incidentList;
  String institution,shopName,details;
  bool shopSelected = false;

  Uint8List incidentBytes,resolutionBytes;
  

  _StaffNonComplianceDashboardState(user,firestoreinstance) {
    this.user = user;
    this.firestoreInstance = firestoreinstance;
  }

  void initState(){
    super.initState();
    //future
  }

  Future<List<dynamic>> updateNonCompliance() async {

    DocumentReference docRef = firestoreInstance.collection('staff').doc(user.uid);
    await docRef.get().then<dynamic>((DocumentSnapshot snapshot) => {
      institution = snapshot.data()['institution']
    });
    QuerySnapshot querySnapshot = await firestoreInstance.collection('institution').doc(institution).collection('tenant').get();

    String inc = '';
    querySnapshot.docs.forEach((doc) {
      inc += doc['shopName'] + ':';

    });

    inc = inc.substring(0,inc.length-1);
    tenantList = inc.split(":");
    setState(() {
      tenantList = tenantList;
    });
  }

  Future<void> getIncidents(int index) async {
    shopName = tenantList[index];
    QuerySnapshot querySnapshot = await firestoreInstance.collection('institution').doc(institution).collection('tenant').doc(shopName).collection('nonComplianceReport').get();
    String unresolved = '';
    String pending = '';
    String resolved = '';

    querySnapshot.docs.forEach((doc){
      if (doc['status'] == 'unresolved'){
        unresolved += doc['incidentName'] + ':';
      } else if (doc['status'] == 'pending'){
        pending += doc['incidentName'] + ':';
      } else if (doc['status'] == 'resolved'){
        resolved += doc['incidentName'] + ':';
      }

    });
    if(unresolved.length > 0) {unresolved = unresolved.substring(0,unresolved.length-1);}
    if(pending.length > 0) {pending = pending.substring(0,pending.length-1);}
    if(resolved.length > 0){resolved = resolved.substring(0,resolved.length-1);}
    incidentList = ['Unresolved Incidents'] + unresolved.split(":") + ['Pending Confirmation'] + pending.split(":") + ['Resolved Incidents'] + resolved.split(":");
    setState(() {
      incidentList = incidentList;
      shopSelected = true;
    });
  }

  bool incidentTitle(String listItem) {
    if (listItem == 'Unresolved Incidents' || listItem == 'Pending Confirmation' || listItem == 'Resolved Incidents') {
      return true;
    } else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) =>
      FutureBuilder(
        future: updateNonCompliance(),
        builder: (context,snapshot){
          if (tenantList == null) {return Center(child: CircularProgressIndicator());}
          else {
            if (shopSelected == false) {
              return Scaffold(
                appBar: AppBar(
                    title: Text("Non Compliance Dashboard")
                ),
                body: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tenantList.length,

                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          height: 50,
                          color: Colors.amber[500],
                          child: RawMaterialButton(
                              child: Center(
                                  child: Text(tenantList[index].toString())),
                              onPressed: () {getIncidents(index);}
                          )

                      );
                    }


                ),

              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Text("Non Compliance Report")
                ),
                body: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: incidentList.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      height: 50,
                      color: incidentTitle(incidentList[index]) ? Colors.amber[500] : Colors.amber[100],
                      child: RawMaterialButton(
                        child: Center(
                          child: Text(incidentList[index]),
                        ),
                        onPressed: incidentTitle(incidentList[index]) ? null : (){navigateToIncidentDetails(incidentList[index]);},

                      )
                    );
                  },

                )
              );
            }
          }


        }
      );
  void navigateToIncidentDetails(String incidentName) async {
    DocumentSnapshot docSnap = await firestoreInstance.collection('institution').doc(institution).collection('tenant').doc(shopName).collection('nonComplianceReport').doc(incidentName).get();
    details = "Location: ${docSnap.data()['location']}\nStatus: ${docSnap.data()['status']}\nSummary: ${docSnap.data()['summary']}";
    QuerySnapshot querySnapshot = await firestoreInstance.collection('institution').doc(institution).collection('tenant').doc(shopName).collection('nonComplianceReport').doc(incidentName).collection('images').get();
    querySnapshot.docs.forEach((element) {
      if (element.id == "incident_image"){
        print(element.data()['data']);
        incidentBytes = Uint8List.fromList(element.data()['data'].cast<int>());
        //print(incidentImage);
      } else if (element.id == "resolution_image") {
        if (element.data()['data'].exists) {
           resolutionBytes = Uint8List.fromList(element.data()['data'].cast<int>());
        }

      }});

    Navigator.push(context, MaterialPageRoute(builder:(context) => StaffDashboardIncidentDetails(user: user, details: details, incidentName: incidentName, incidentBytes: incidentBytes, resolutionBytes: resolutionBytes)));
  }


}