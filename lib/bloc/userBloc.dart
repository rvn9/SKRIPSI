// import 'package:bloc/bloc.dart';
// import 'package:skripsi/models/userModel.dart';
// import 'package:skripsi/repo/userRepo.dart';
//
// enum UserEvents { getUser, createUser }
//
// class UserState {
//   User user;
//   bool isLoading;
//   bool isLoaded;
//   bool isDeleting;
//   bool isDeleted;
//   bool isSaved;
//   bool hasFailure;
//   bool isSaving;
//
//   UserState({
//     this.user,
//     this.isLoading = false,
//     this.isSaved = false,
//     this.isDeleting = false,
//     this.isDeleted = false,
//     this.isSaving = false,
//     this.hasFailure = false,
//     this.isLoaded = false,
//   });
// }
//
// class UserBloc extends Bloc<UserEvents, UserState> {
//   UserRepository _userRepository;
//
//   UserBloc() : super(null) {
//     _userRepository = UserRepository();
//   }
//
//   User _user;
//
//   @override
//   UserState get initialState => UserState();
//
//   void createUser(User user) {
//     _user = user;
//     this.add(UserEvents.createUser);
//   }
//
//
//   @override
//   Stream<UserState> mapEventToState(UserEvents event) async* {
//     switch(event){
//       //create new user //
//       case UserEvents.createUser:
//         bool isSuccessful = await _userRepository.createUser(_user);
//         yield UserState(
//             isSaving: false, isSaved: isSuccessful, hasFailure: !isSuccessful);
//         break;
//       // get specific user //
//       case UserEvents.getUser:
//         yield UserState(isLoading: true, isLoaded: false);
//         User user = await _userRepository.getUserById(_user.tagId);
//         yield UserState(user: user, isLoading: false, isLoaded: true);
//         break;
//       default:
//         addError(Exception('unsupported event'));
//     }
//   }
//
//   // void getUser(String tagID) {
//   //   _tagID = tagID;
//   //   this.dispatch(UserEvents.getUser);
//   // }
//   //
//   // void createUser(User user) {
//   //   _user = user;
//   //   this.dispatch(UserEvents.createUser);
//   // }
//
//   // void updateUser(User user) {
//   //   _user = user;
//   //   this.dispatch(UserEvents.updateUser);
//   // }
//   //
//   // void deleteUser(String id) {
//   //   _id = id;
//   //   this.dispatch(UserEvents.deleteUser);
//   // }
//
//   // @override
//   // Stream<UserState> mapEventToState(
//   //     UserState currentState, UserEvents event) async* {
//   //   switch (event) {
//   //     case UserEvents.getUser:
//   //       yield UserState(isLoading: true, isLoaded: false);
//   //       User user = await _userRepository.getUserById(_id);
//   //       yield UserState(user: user, isLoading: false, isLoaded: true);
//   //       break;
//   //
//   //     case UserEvents.createUser:
//   //       yield UserState(isSaving: true, isSaved: false);
//   //       bool isSuccessful = await _userRepository.createUser(_user);
//   //       yield UserState(
//   //           isSaving: false, isSaved: isSuccessful, hasFailure: !isSuccessful);
//   //       break;
//   //
//   //     // case UserEvents.updateUser:
//   //     //   yield UserState(
//   //     //     isSaving: true,
//   //     //     isSaved: false,
//   //     //   );
//   //     //
//   //     //   bool isSuccessful = await _userRepository.updateUser(_user);
//   //     //
//   //     //   yield UserState(
//   //     //     isSaving: false,
//   //     //     isSaved: isSuccessful,
//   //     //     hasFailure: !isSuccessful,
//   //     //   );
//   //     //   break;
//   //
//   //     // case UserEvents.deleteUser:
//   //     //   yield UserState(
//   //     //     isDeleting: true,
//   //     //     isDeleted: false,
//   //     //   );
//   //     //
//   //     //   bool isSuccessful = await _userRepository.deleteUser(_id);
//   //     //
//   //     //   yield UserState(
//   //     //     isDeleting: false,
//   //     //     isDeleted: isSuccessful,
//   //     //     hasFailure: !isSuccessful,
//   //     //   );
//   //     //   break;
//   //   }
//   // }
// }