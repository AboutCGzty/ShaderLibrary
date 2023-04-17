using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Cat cat = new Cat();
        cat.Age = "2岁";
        cat.Walk();
        Animal animal = new Animal();
        animal.Walk();
        //Dog dog = new Dog();
        //Fish fish = new Fish();
        //Debug.LogError(typeof(Cat).BaseType); //typeof输出的是()中的类型
    }
}

// 基类
class Animal
{
    public string Name { get; set; }
    public string Age { get; set; }

    virtual public void Walk() // 增加virtual 就变成了虚方法
    {
        Debug.LogError("走路");
    }
}

class Cat : Animal
{
    public void CatchMouse()
    {
        Debug.LogError("抓老鼠");
    }

    override public void Walk() // override 就变成了覆写方法
    {
        Debug.LogError("走路");
    }
}

class Dog : Animal
{
    public void GuardHouse()
    {
        Debug.LogError("看家");
    }
}

class Fish : Animal
{
    public void Swimming()
    {
        Debug.LogError("游来游去");
    }
}