using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;

public class ShaderReset
{
    //��ȡshader�����еĺ�
    public static bool GetShaderKeywords(Shader target, out string[] global, out string[] local)
    {
        try
        {
            MethodInfo globalKeywords = typeof(ShaderUtil).GetMethod("GetShaderGlobalKeywords", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
            global = (string[])globalKeywords.Invoke(null, new object[] { target });
            MethodInfo localKeywords = typeof(ShaderUtil).GetMethod("GetShaderLocalKeywords", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
            local = (string[])localKeywords.Invoke(null, new object[] { target });
            return true;
        }
        catch
        {
            global = local = null;
            return false;
        }
    }

    [MenuItem("��������/������ɫ��")]
    static void Test222()
    {
        //�����滻���Լ��Ĳ��ʣ�Ҳ������ȱ������������еĲ���
        Material m = AssetDatabase.LoadAssetAtPath<Material>("Assets/aa223.mat");
        if (GetShaderKeywords(m.shader, out var global, out var local))
        {
            HashSet<string> keywords = new HashSet<string>();
            foreach (var g in global)
            {
                keywords.Add(g);
            }
            foreach (var l in local)
            {
                keywords.Add(l);
            }
            //����keywords
            List<string> resetKeywords = new List<string>(m.shaderKeywords);
            foreach (var item in m.shaderKeywords)
            {
                if (!keywords.Contains(item))
                    resetKeywords.Remove(item);
            }
            m.shaderKeywords = resetKeywords.ToArray();
        }
        HashSet<string> property = new HashSet<string>();
        int count = m.shader.GetPropertyCount();
        for (int i = 0; i < count; i++)
        {
            property.Add(m.shader.GetPropertyName(i));
        }

        SerializedObject o = new SerializedObject(m);
        SerializedProperty disabledShaderPasses = o.FindProperty("disabledShaderPasses");
        SerializedProperty SavedProperties = o.FindProperty("m_SavedProperties");
        SerializedProperty TexEnvs = SavedProperties.FindPropertyRelative("m_TexEnvs");
        SerializedProperty Floats = SavedProperties.FindPropertyRelative("m_Floats");
        SerializedProperty Colors = SavedProperties.FindPropertyRelative("m_Colors");

        //�Ա�����ɾ������������
        for (int i = disabledShaderPasses.arraySize - 1; i >= 0; i--)
        {
            if (!property.Contains(disabledShaderPasses.GetArrayElementAtIndex(i).displayName))
            {
                disabledShaderPasses.DeleteArrayElementAtIndex(i);
            }
        }
        for (int i = TexEnvs.arraySize - 1; i >=0; i--)
        {
            if (!property.Contains(TexEnvs.GetArrayElementAtIndex(i).displayName))
            {
                TexEnvs.DeleteArrayElementAtIndex(i);
            }
        }
        for (int i = Floats.arraySize - 1; i >= 0; i--)
        {
            if (!property.Contains(Floats.GetArrayElementAtIndex(i).displayName))
            {
                Floats.DeleteArrayElementAtIndex(i);
            }
        }
        for (int i = Colors.arraySize - 1; i >= 0; i--)
        {
            if (!property.Contains(Colors.GetArrayElementAtIndex(i).displayName))
            {
                Colors.DeleteArrayElementAtIndex(i);
            }
        }
        o.ApplyModifiedProperties();

        Debug.Log("Done!");
    }
}
