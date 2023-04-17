using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Cat cat = new Cat();
        cat.Age = "2��";
        cat.Walk();
        Animal animal = new Animal();
        animal.Walk();
        //Dog dog = new Dog();
        //Fish fish = new Fish();
        //Debug.LogError(typeof(Cat).BaseType); //typeof�������()�е�����
    }
}

// ����
class Animal
{
    public string Name { get; set; }
    public string Age { get; set; }

    virtual public void Walk() // ����virtual �ͱ�����鷽��
    {
        Debug.LogError("��·");
    }
}

class Cat : Animal
{
    public void CatchMouse()
    {
        Debug.LogError("ץ����");
    }

    override public void Walk() // override �ͱ���˸�д����
    {
        Debug.LogError("��·");
    }
}

class Dog : Animal
{
    public void GuardHouse()
    {
        Debug.LogError("����");
    }
}

class Fish : Animal
{
    public void Swimming()
    {
        Debug.LogError("������ȥ");
    }
}