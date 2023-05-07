using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

using System.Collections.Concurrent;

namespace xk_System
{
	//Object 池子
	public class ObjectPool<T> where T : class, new()
	{
		Queue<T> mObjectPool = null;

		public ObjectPool(int initCapacity = 0)
		{
			mObjectPool = new Queue<T>();
			for (int i = 0; i < initCapacity; i++)
			{
				mObjectPool.Enqueue(new T());
			}
		}

		public int Count()
		{
			return mObjectPool.Count;
		}

		public T Pop()
		{
			if (mObjectPool.Count > 0)
			{
				return mObjectPool.Dequeue();
			}
			else
			{
				return new T();
			}
		}

		public void recycle(T t)
		{
			mObjectPool.Enqueue(t);
		}

		public void release()
		{
			mObjectPool.Clear();
			mObjectPool = null;
		}
	}

	public class SafeObjectPool<T> where T : class, new()
	{
		private ConcurrentQueue<T> mObjectPool = null;

		public SafeObjectPool(int initCapacity = 0)
		{
			mObjectPool = new ConcurrentQueue<T>();
			for (int i = 0; i < initCapacity; i++)
			{
				mObjectPool.Enqueue(new T());
			}
		}

		public int Count()
		{
			return mObjectPool.Count;
		}

		public T Pop()
		{
			T t = null;

			if (!mObjectPool.TryDequeue(out t))
			{
				t = new T();
			}

			return t;
		}

		public void recycle(T t)
		{
			mObjectPool.Enqueue(t);
		}

		public void release()
		{
			mObjectPool = null;
		}
	}

	public class ArrayGCPool<T>
	{
		Dictionary<int, Queue<T[]>> mPoolDic = null;

		public ArrayGCPool()
		{
			mPoolDic = new Dictionary<int, Queue<T[]>>();
		}

		public void recycle(T[] array)
		{
			Array.Clear(array, 0, array.Length);

			Queue<T[]> arrayQueue = null;
			if (!mPoolDic.TryGetValue(array.Length, out arrayQueue))
			{
				arrayQueue = new Queue<T[]>();
				mPoolDic.Add(array.Length, arrayQueue);
			}

			arrayQueue.Enqueue(array);
		}

		public T[] Pop(int Length)
		{
			Queue<T[]> arrayQueue = null;
			if (!mPoolDic.TryGetValue(Length, out arrayQueue))
			{
				arrayQueue = new Queue<T[]>();
			}

			T[] array = null;
			if (arrayQueue.Count > 0)
			{
				array = arrayQueue.Dequeue();
			}
			else
			{
				array = new T[Length];
			}
			return array;
		}

		public void release()
		{
			mPoolDic = null;
		}
	}

	public class SafeArrayGCPool<T>
	{
		ConcurrentDictionary<int, ConcurrentQueue<T[]>> mPoolDic = new ConcurrentDictionary<int, ConcurrentQueue<T[]>>();

		public SafeArrayGCPool()
		{
			mPoolDic = new ConcurrentDictionary<int, ConcurrentQueue<T[]>>();
		}

		public void recycle(T[] array)
		{
			Array.Clear(array, 0, array.Length);

			ConcurrentQueue<T[]> arrayQueue = null;
			if (!mPoolDic.TryGetValue(array.Length, out arrayQueue))
			{
				arrayQueue = new ConcurrentQueue<T[]>();
				mPoolDic.TryAdd(array.Length, arrayQueue);
			}

			arrayQueue.Enqueue(array);
		}

		public T[] Pop(int Length)
		{
			ConcurrentQueue<T[]> arrayQueue = null;
			if (!mPoolDic.TryGetValue(Length, out arrayQueue))
			{
				arrayQueue = new ConcurrentQueue<T[]>();
			}

			T[] array = null;
			if (!arrayQueue.TryDequeue(out array))
			{
				array = new T[Length];
			}

			return array;
		}

		public void release()
		{
			mPoolDic = null;
		}
	}

}