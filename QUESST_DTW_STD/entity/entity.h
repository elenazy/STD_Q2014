// Entity.h
//
// //Copyright 2016  NORTHWESTERN　POLYTECHNICAL UNIVERSITY(Author: jyhou@nwpu-aslp.org)
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //  http://www.apache.org/licenses/LICENSE-2.0
// //
// // THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// // WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// // MERCHANTABLITY OR NON-INFRINGEMENT.
// // See the Apache 2 License for the specific language governing permissions and
// // limitations under the License.

#ifndef ENTITY_ENTITY_H_
#define ENTITY_ENTITY_H_

#include <iostream>
#include <fstream>
#include <string>
#include <infra.h>
namespace aslp {
class Entity {
private:

public:
    Entity() {}
    Entity(std::string file_id);
    Entity &operator = (const Entity& other);

    ~Entity();

ls
}


} //namespace aslp
#endif //ENTITY_ENTITY_H_ 
