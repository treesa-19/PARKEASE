
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:park_ease/Screeens/Dashboard/spotfindloc.dart';
import 'package:park_ease/Screeens/profile/profile.dart';
import 'package:park_ease/Screeens/Dashboard/countshow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> locations = [];
  String? selectedLocation;
  List<String> spots= [];
  String? selectedSpot;
  String?loc_id;
  String?spot_id;
  String?latlng;
  bool enableDropdownButton =false;
  final FirebaseAuth auth=FirebaseAuth.instance;


  String? name;
  String? profileimageurl;

  @override
  void initState() {
    super.initState();
    fetchdata();
    fetchlocs();
    print('the initail location is **************************************$selectedLocation');
  }

  Future<void> fetchlocs() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    print('the after fecthlocs location is **************************************$selectedLocation');
    if (firebaseUser != null) {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .get();


      Stream<QuerySnapshot> productRef = FirebaseFirestore.instance
          .collection("locations")
          .snapshots();
      productRef.forEach((field) {
        field.docs.asMap().forEach((index, data) {
          locations.add(field.docs[index]["name"]);
          print(field.docs[index]["name"]);
        });
      });


    }


  }




  Future<String?> fetchDocumentId(String collectionPath, String fieldName, dynamic searchValue) async {
    if (searchValue == null) {
      return null; // Return null if search value is null
    }

    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionPath)
        .where(fieldName, isEqualTo: searchValue)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot document = snapshot.docs.first;

      return document.id;
    }

    return null; // Document with the given field value not found
  }

  Future<String?> fetchspotDocumentId(String collectionPath, String fieldName, dynamic searchValue) async {
    if (searchValue == null) {
      return null; // Return null if search value is null
    }

    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionPath)
        .where(fieldName, isEqualTo: searchValue)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot document = snapshot.docs.first;

      return document.id;
    }

    return null; // Document with the given field value not found
  }

  Future<void> fetchspots() async {
    spots=[];

    print('the fecthspot location is **************************************$selectedLocation');
    String? documentId = await fetchDocumentId('locations', 'name',selectedLocation);
    print(selectedLocation);
    print(documentId);
    if (documentId != null) {
      // Document ID found
      loc_id=documentId;
      print(loc_id);
      enableDropdownButton=true;
      print('Document ID: $documentId');
    } else {
      // Document not found
      print('Document not found.');
    }

    Stream<QuerySnapshot> productRef = FirebaseFirestore.instance
        .collection("spots").where('locid', isEqualTo: documentId)
        .snapshots();
    productRef.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        spots.add(field.docs[index]["name"]);
        print(field.docs[index]["name"]);
      });
    });
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!$spots');

  }


  Future<void> fetchdata() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        final fetchedname = data?['name'];
        final fetchedprofimageurl=data?['profileImageUrl'];
        if (mounted) {
          setState(() {
            name = fetchedname;
            profileimageurl=fetchedprofimageurl;
            
          });
        }
        print(profileimageurl);
        print(name);
      } else {
        print('Document does not exist');
      }

    }
  }
  Widget listItem() {
    return Container(
      padding: const EdgeInsets.all(Material.defaultSplashRadius),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Text(
            'HELLO ${name},',
            style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.normal, color: Colors.white),
          ),
          const SizedBox(
            height: 80,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Color(0xffDDCA1C),
            ),
            child: ListTile(
                onTap: (){
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => NearbySpotsScreen()));

                },
                leading: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xffDDCA1C).withOpacity(0.1)
                  ),
                  child: Icon(FontAwesomeIcons.mapLocation, color:Colors.blue),
                ),
                title: Text(

                    'Find Nearby Spots',style: TextStyle(fontSize: 20,color: Colors.white)),
                trailing: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xffDDCA1C)
                  ),


                )
            ),
          ),
          const SizedBox(height:20),
          Center(child: SizedBox(
            width:60,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white70
              ),
              padding: EdgeInsets.all(16),

              child: Text('OR',textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 14),
              ),
            ),
          ),),
          const SizedBox(height:20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Color(0xffDDCA1C),
            ),
            child: ListTile(
                onTap: (){    showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: DropdownButton<String>(
                        value: selectedLocation,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLocation = newValue;
                            fetchspots();
                            print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$spots');
                          });
                          Navigator.pop(context);
                        },
                        items: locations.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );

                },
                leading: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xffDDCA1C).withOpacity(0.1)
                  ),
                  child: Icon(FontAwesomeIcons.locationDot, color:Colors.red),
                ),
                title: Text(

                    selectedLocation??'Choose Location',style: TextStyle(fontSize: 20,color: Colors.white)),
                trailing: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xff1A1919).withOpacity(0.1)
                  ),
                  child: const Icon(FontAwesomeIcons.circleChevronDown, color:Colors.white70),

                )
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Color(0xffDDCA1C),
            ),

            child: ListTile(
              onTap: () {
                print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^$spots');
                if(enableDropdownButton){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select Spot'),
                      content: DropdownButton<String>(

                        value: selectedSpot,
                        onChanged: (String? newValue) { // Update the parameter type to be nullable
                          setState(() {
                            selectedSpot = newValue;
                          });
                          Navigator.pop(context);
                        },
                        items: spots.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );}
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Select location first'),
                        content: IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon:Icon(FontAwesomeIcons.circleChevronLeft)



                        ),

                      );
                    },
                  );
                }
              },
              leading: Container(
                // width: 30,
                // height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Color(0xffDDCA1C).withOpacity(0.1),
                ),
                child: Icon(FontAwesomeIcons.squareParking, color: Colors.black),
              ),
              title: Text(
                selectedSpot??'Choose Spot',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Color(0xffDDCA1C).withOpacity(0.1),
                ),
                child: const Icon(FontAwesomeIcons.circleChevronDown, color: Colors.white70),
              ),
            ),
          ),


          const SizedBox(
            height: 100,
          ),
          SizedBox(width:200,height: 45,
            child: ElevatedButton.icon(
                onPressed: () async {
                  String? spotdocumentId = await fetchspotDocumentId('spots','name',selectedSpot);
                  spot_id=spotdocumentId;
                  print(spot_id);
                  if(spot_id!=null && loc_id!=null) {
                   print('');
                    //

                  }
                  else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Select spot'),
                          content: IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon:Icon(FontAwesomeIcons.circleChevronLeft)



                          ),

                        );
                      },
                    );
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FetchData (spott_id: spot_id??'')));
                },
                icon: Icon(FontAwesomeIcons.search,color: Colors.black,),
                label: Text('Search',style: TextStyle(fontSize: 18,color: Colors.black)),
                style:ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70, side: BorderSide.none, shape: StadiumBorder()
                )
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xff1A1919),
        appBar: AppBar(

            leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              icon: SizedBox(
                  width: 140,
                  height: 140,
                  child:ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      profileimageurl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback widget to display when an error occurs
                        return Image.asset(
                          'assets/images/profilesample.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),),
            ),
            title:FittedBox(fit: BoxFit.fitWidth, child: Text('$name '??'',style: TextStyle(fontStyle: FontStyle.normal,fontSize:18,color: Colors.white ),)),


            //FittedBox(fit: BoxFit.fitWidth, child: Text('Hello!\n$name '??'',style: TextStyle(fontStyle: FontStyle.italic,fontSize:18 ),)),
            // actions: [Text('HELLO')],


             backgroundColor: Colors.transparent,

            elevation: 0.0,
          ),

        body:
        listItem(),




    );
  }
}
class CircularBottomAppBarBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = super.getOuterPath(rect, textDirection: textDirection);
    final radius = Radius.circular(20); // Set the desired circular radius

    path.addRRect(RRect.fromRectAndCorners(
      rect,
      bottomLeft: radius,
      bottomRight: radius,
    ));

    return path;
  }
}