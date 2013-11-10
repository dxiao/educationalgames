Module = {}
window.ModelData = Module

ClassModel = window.ClassModel

ModelData.simple = {
  types: [
    new ClassModel.Interface "Drinkable"
    new ClassModel.Class "Coffee"
    new ClassModel.Class "MochaLatte"
  ]
}
